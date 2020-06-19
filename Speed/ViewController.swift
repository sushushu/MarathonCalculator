//
//  ViewController.swift
//  Speed
//
//  Created by Aiagain on 2019/10/8.
//  Copyright © 2019 sl. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import SnapKit
import RxCocoa


// 1英里 =  1,609.34米 = 1.61 公里

class ViewController: UIViewController,UITextFieldDelegate {
    
    lazy var m_imageView = UIImageView()
    lazy var firstLabel = UILabel()
    lazy var secondLabel = UILabel()
    lazy var timeContainView = UIView()
    lazy var hoursTF = UITextField()
    lazy var minutesTF = UITextField()
    lazy var secondsTF = UITextField()
    lazy var distanceTF = UITextField()
    lazy var speedContainView = UIView()
    lazy var sp_minutesTF = UITextField()
    lazy var sp_secondsTF = UITextField()
    
    lazy var resLabel = UILabel()
    lazy var cleanButton = UIButton()
    lazy var calculeTimeButton = UIButton()
    lazy var calculeDistanceButton = UIButton()
    lazy var calculeSpeedButton = UIButton()
    let distanceTitles = ["1km","5km","10km","half","full"]
    lazy var segement = UISegmentedControl(items: distanceTitles)
    let margin = 10
    let tfTextColor = UIColor.black
    let calBackGroundColor = UIColor.black
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUIs ()

        doTimeShit()
        doDistanceShit()
        doSpeedShit()
        someFuckingWorkForTextField()
    }
    
    
    // MARK: - buttons shit
    
    // 计算时间
    private func doTimeShit() {
        let timeObvs = calculeTimeButton.rx.tap.asObservable()
        timeObvs.bind(onNext: {
            (res) in
            
            self.setButtonTitleColorHighlight(btn: self.calculeTimeButton)
            self.registerTFs()

            // 空值判断
            if (self.distanceTF.text == "") { self.distanceTF.text = "0" }
            if (self.sp_minutesTF.text == "") { self.sp_minutesTF.text = "0" }
            if (self.sp_secondsTF.text == "") { self.sp_secondsTF.text = "0" }

            if (self.distanceTF.text == "0" ) { self.alert("距离不能为0"); return; }
            if (self.sp_minutesTF.text == "0" && self.sp_secondsTF.text == "0") { self.alert("分和秒配速不能都为0"); return; }

            // TODO: 太大或者太小判断
            // TODO: 禁止复制暂停 禁止输入符号和英文
            // TODO: 限制不能超过3位数
            let d = Float(self.distanceTF.text!)! // km
            let m = Float(self.sp_minutesTF.text!)! // min
            let s = Float(self.sp_secondsTF.text!)! // sencond

            print(" 距离: \(d)km  配速：\(m)分钟 \(s)秒 ")

            let meter = d
            let second = m * 60 + s // 转换为秒

            let allTime = Int(meter * second) // 距离 * 秒速
            var hours = 0
            var minutes = 0
            var seconds = 0
            var hoursText = ""
            var minutesText = ""
            var secondsText = ""

            hours = allTime / 3600
            hoursText = hours > 9 ? "\(hours)" : "\(hours)"

            minutes = allTime % 3600 / 60
            minutesText = minutes > 9 ? "\(minutes)" : "\(minutes)"

            seconds = allTime % 3600 % 60
            secondsText = seconds > 9 ? "\(seconds)" : "\(seconds)"

            print(" 需要的总时间： \(hoursText)小时  \(minutesText)分  \(secondsText)秒  \n \n")

            self.hoursTF.text = hoursText
            self.minutesTF.text = minutesText
            self.secondsTF.text = secondsText

        }).disposed(by: disposeBag)
    }
    
    // 计算距离
    private func doDistanceShit() {
        let distanceObvs = calculeDistanceButton.rx.tap.asObservable()
        distanceObvs.bind(onNext: {
            (res) in
            
            self.setButtonTitleColorHighlight(btn: self.calculeDistanceButton)
            self.registerTFs()
            
            // 空值判断
            if (self.hoursTF.text == "") { self.hoursTF.text = "0" }
            if (self.minutesTF.text == "") { self.minutesTF.text = "0" }
            if (self.secondsTF.text == "") { self.secondsTF.text = "0" }
            if (self.sp_minutesTF.text == "") { self.sp_minutesTF.text = "0" }
            if (self.sp_secondsTF.text == "") { self.sp_secondsTF.text = "0" }
            
            // TODO: 太大或者太小判断
            // TODO: 禁止复制暂停 禁止输入符号和英文
            // TODO: 限制不能超过3位数

            let hours = Float(self.hoursTF.text!)!
            let minutes = Float(self.minutesTF.text!)!
            let seconds = Float(self.secondsTF.text!)!
            let m = Float(self.sp_minutesTF.text!)! // min
            let s = Float(self.sp_secondsTF.text!)! // sencond
            
            print(" \n 配速：\(m)分 \(s)秒 \n \n")
            
            // 距离 = 总时间/速度
            let totalTime = hours * 60.0 * 60.0 + minutes * 60.0 + seconds
            let totalSpeed = m * 60 + s
            
            if (totalSpeed == 0 ) {
                self.alert("要输入配速鸭")
                return;
            }
            let res = String(format: "%.2f", (totalTime/totalSpeed)) // 同单位相除即可
            self.distanceTF.text = res
            
            print("总距离（km）： \(res)")
        }).disposed(by: disposeBag)
    }
    
    // 计算配速
    private func doSpeedShit() {
        let distanceObvs = calculeSpeedButton.rx.tap.asObservable()
        distanceObvs.bind(onNext: {
            (res) in
            
            self.setButtonTitleColorHighlight(btn: self.calculeSpeedButton)
            self.registerTFs()
            
            // 空值判断
            if (self.distanceTF.text == "") { self.distanceTF.text = "0" }
            if (self.hoursTF.text == "") { self.hoursTF.text = "0" }
            if (self.minutesTF.text == "") { self.minutesTF.text = "0" }
            if (self.secondsTF.text == "") { self.secondsTF.text = "0" }
            
            // TODO: 太大或者太小判断
            // TODO: 禁止复制暂停 禁止输入符号和英文
            // TODO: 限制不能超过3位数

            let totalDistance = Float(self.distanceTF.text!)!
            let hours = Float(self.hoursTF.text!)!
            let minutes = Float(self.minutesTF.text!)!
            let seconds = Float(self.secondsTF.text!)!

            print(" 距离：\(totalDistance)km ， 时间：\(hours)小时 \(minutes)分 \(seconds)秒 ")
            
            if (totalDistance == 0) {
                self.alert("抱歉，距离为0可算不了~")
                return;
            }
            
            // 全部转换为分钟再算
            let totalMinutes = hours * 60 + minutes + (seconds/60)
            let allTime = Int((totalMinutes/totalDistance * 60))
            var t_hours = 0
            var t_minutes = 0
            var t_seconds = 0
            var hoursText = ""
            var minutesText = ""
            var secondsText = ""
            
            t_hours = allTime / 3600
            hoursText = hours > 9 ? "\(t_hours)" : "\(t_hours)"
            
            t_minutes = allTime % 3600 / 60
            minutesText = minutes > 9 ? "\(t_minutes)" : "\(t_minutes)"
                
            t_seconds = allTime % 3600 % 60
            secondsText = seconds > 9 ? "\(t_seconds)" : "\(t_seconds)"
           
            print(" 配速为： \(hoursText)小时  \(minutesText)分  \(secondsText)秒  \n \n")
            
            self.sp_minutesTF.text = "\(t_hours * 60 + t_minutes)" // 适配超过1小时的情况
            self.sp_secondsTF.text = secondsText
            
        }).disposed(by: disposeBag)
    }
    

    private func someFuckingWorkForTextField() {
        // 设置segment
        let segementObvs = segement.rx.selectedSegmentIndex.asObservable()
        segementObvs.bind (onNext: { (res) in
            self.registerTFs()
            switch res {
            case 0:
                self.distanceTF.text = String("1.0")
            case 1:
                self.distanceTF.text = String("5.0")
            case 2:
                self.distanceTF.text = String("10.0")
            case 3:
                self.distanceTF.text = String("21.0975")
            case 4:
                self.distanceTF.text = String("42.195")
            default:
                print("mao~")
            }
        }).disposed(by: disposeBag)
        
        // 清空所有textField
        _ = cleanButton.rx.tap.bind(onNext: { _ in
            self.setButtonTitleColorHighlight(btn: self.cleanButton)
            for view in self.view.subviews {
                self.resetAlltheTextField(view)
                self.registerTFs()
            }
        })
        
        self.hoursTF.delegate = self
        self.minutesTF.delegate = self
        self.secondsTF.delegate = self
        self.distanceTF.delegate = self
        self.sp_minutesTF.delegate = self
        self.sp_secondsTF.delegate = self
    }
    
    
    
    // MARK: - textField delegate
    
    // 该方法当文本框内容出现变化时 及时获取文本最新内容
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.distanceTF {
            // 判断是否有1个以上的小数点
            var res = 0
            let totalString = self.distanceTF.text! + string
            for search in totalString {
                if search == "." {
                    res += 1
                }
                if res > 1 {
                    return false
                }
            }
        }
        
        // 获取输入的文本，移除向输入框中粘贴文本时，系统自动加上的空格（iOS11上有该问题）
        let new = string.replacingOccurrences(of: " ", with: "")
        // 获取编辑前的文本
        var old = NSString(string: textField.text ?? "")
        // 获取编辑后的文本
        old = old.replacingCharacters(in: range, with: new) as NSString
        // 获取数字的字符集
        var number = CharacterSet(charactersIn: "0123456789")
        if textField == self.distanceTF {
            number = CharacterSet(charactersIn: ".0123456789")
        }
        // 判断编辑后的文本是否全为数字
        if old.rangeOfCharacter(from: number.inverted).location == NSNotFound {
            // number.inverted表示除了number中包含的字符以外的其他全部字符
            // 如果old中不包含其他字符，则格式正确
            // 允许本次编辑
            textField.text = old as String
            // 移动光标的位置
            DispatchQueue.main.async {
                let beginning = textField.beginningOfDocument
                let position = textField.position(from: beginning, offset: range.location + new.count)!
                textField.selectedTextRange = textField.textRange(from: position, to: position)
            }
        }
        
        return false
    }
    


    // MARK: - init UIs
    
    private func initUIs () {
        initImageView()
        initTimeTextField ()
        initSegment ()
        initDistanceTextField ()
        initSpeedView ()
        initCleanButton ()
        initCalculeButtons ()
    }
    
    private func initImageView () {
        self.m_imageView = UIImageView.init(image: UIImage(named: "nike_icon"))
        self.view.addSubview( self.m_imageView)
        self.m_imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.view.frame.size.height * 0.35)
        }
    }
    
    private func initTimeTextField () {
        timeContainView.layer.borderWidth = 1
        timeContainView.layer.borderColor = UIColor.gray.cgColor
        self.view.addSubview(timeContainView)
        timeContainView.addSubview(hoursTF)
        timeContainView.addSubview(minutesTF)
        timeContainView.addSubview(secondsTF)
        self.view.addSubview(speedContainView)
        
        timeContainView.snp.makeConstraints { (make) in
            make.left.equalTo(margin)
//            if (secondLabel != nil) {
//                make.top.equalTo(secondLabel.snp_bottomMargin).offset(self.view.frame.size.height * 0.20)
//            } else {
                make.top.equalTo(self.m_imageView.snp_bottomMargin).offset(30)
//            }

            make.right.equalTo(-(self.view.frame.size.width * 0.25))
            make.height.equalTo(50)
        }
        
        let array = [hoursTF,minutesTF,secondsTF]
        let leftView1 = UILabel()
        leftView1.text = " 小时  "
        
        let leftView2 = UILabel()
        leftView2.text = " 分  "
        
        let leftView3 = UILabel()
        leftView3.text = " 秒 "
        
        let leftViews = [leftView1,leftView2,leftView3]
        
        for item in array.enumerated() {
            item.element.keyboardType = .numberPad
            item.element.textAlignment = .center
            item.element.rightView = leftViews[item.offset]
            item.element.rightViewMode = .always
            item.element.tintColor = UIColor.black.withAlphaComponent(0.7)
            item.element.textColor = tfTextColor
        }
        
        array.snp.distributeViewsAlong(axisType: .horizontal , fixedSpacing: 0 , leadSpacing: 0 , tailSpacing: 0)
        array.snp.makeConstraints{
            $0.height.equalTo(48)
        }
    }
    
    private func initSegment () {
        segement.selectedSegmentIndex = 0
        self.view.addSubview(segement)
        segement.snp.makeConstraints { (make) in
            make.top.equalTo(timeContainView.snp_bottomMargin).offset(30)
            make.left.equalTo(timeContainView)
            make.right.equalTo(timeContainView)
            make.height.equalTo(50)
        }
    }
    
    private func initDistanceTextField () {
        let leftView1 = UILabel()
        leftView1.text = "  距离(km):  "
        distanceTF.textColor = tfTextColor
        distanceTF.leftView = leftView1
        distanceTF.leftViewMode = .always
        distanceTF.keyboardType = .decimalPad
        distanceTF.tintColor = UIColor.black.withAlphaComponent(0.7)
        distanceTF.layer.borderWidth = 1
        distanceTF.layer.borderColor = UIColor.gray.cgColor
        self.view.addSubview(distanceTF)
        distanceTF.snp.makeConstraints { (make) in
            make.top.equalTo(segement.snp_bottomMargin).offset(margin)
            make.left.equalTo(timeContainView)
            make.right.equalTo(timeContainView)
            make.height.equalTo(50)
        }
    }
    
    private func initSpeedView () {
        speedContainView.layer.borderWidth = 1
        speedContainView.layer.borderColor = UIColor.gray.cgColor
        self.view.addSubview(speedContainView)
        speedContainView.addSubview(sp_minutesTF)
        speedContainView.addSubview(sp_secondsTF)
        speedContainView.snp.makeConstraints { (make) in
            make.top.equalTo(distanceTF.snp_bottomMargin).offset(30)
            make.left.equalTo(timeContainView)
            make.right.equalTo(timeContainView)
            make.height.equalTo(50)
        }

        let array = [sp_minutesTF,sp_secondsTF]
        
        let leftView2 = UILabel()
        leftView2.text = "   分  "
        
        let leftView3 = UILabel()
        leftView3.text = "   秒  "
        
        let leftViews = [leftView2,leftView3]
        
        for item in array.enumerated() {
            item.element.keyboardType = .numberPad
            item.element.textAlignment = .center
            item.element.rightView = leftViews[item.offset]
            item.element.rightViewMode = .always
            item.element.tintColor = UIColor.black.withAlphaComponent(0.7)
            item.element.textColor = tfTextColor
        }
        
        array.snp.distributeViewsAlong(axisType: .horizontal , fixedSpacing: 0 , leadSpacing: 0 , tailSpacing: 0)
        array.snp.makeConstraints{
            $0.height.equalTo(48)
        }
    }
    
    private func initCleanButton () {
        cleanButton.backgroundColor = tfTextColor
        cleanButton.layer.cornerRadius = 25
        cleanButton.showsTouchWhenHighlighted = true
        cleanButton.setTitle("清 空", for: .normal)
        self.view.addSubview(cleanButton)
        cleanButton.snp.makeConstraints { (make) in
            make.top.equalTo(speedContainView.snp_bottomMargin).offset(30)
            make.width.equalTo(self.view.frame.size.width * 0.3)
            make.height.equalTo(50)
            make.centerX.equalTo(speedContainView)
        }
    }
    
    private func initCalculeButtons () {
        let views = [calculeTimeButton,calculeDistanceButton,calculeSpeedButton]
        calculeTimeButton.setTitle("计算总耗时", for: .normal)
        calculeDistanceButton.setTitle("计算总距离", for: .normal)
        calculeSpeedButton.setTitle("计算配速", for: .normal)
        for item in views {
            item.showsTouchWhenHighlighted = true
            item.layer.cornerRadius = 25
            item.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            item.backgroundColor = calBackGroundColor
        }
        
        self.view.addSubview(calculeTimeButton)
        self.view.addSubview(calculeDistanceButton)
        self.view.addSubview(calculeSpeedButton)
        
        calculeTimeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeContainView)
            make.left.equalTo(timeContainView.snp_rightMargin).offset(margin * 2)
            make.right.equalTo(self.view).offset(-margin)
            make.height.equalTo(timeContainView)
        }
        calculeDistanceButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(distanceTF)
            make.left.equalTo(distanceTF.snp_rightMargin).offset(margin * 2)
            make.right.equalTo(self.view).offset(-margin)
            make.height.equalTo(distanceTF)
        }
        calculeSpeedButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(speedContainView)
            make.left.equalTo(speedContainView.snp_rightMargin).offset(margin * 2)
            make.right.equalTo(self.view).offset(-margin)
            make.height.equalTo(speedContainView)
        }
    }
    

    // MARK: - overwrite
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        registerTFs()
    }
    
    
    // MARK: - private
    
    /// 重置所有textfield的值
    private func resetAlltheTextField(_ view : UIView) {
        if let res = view as? UITextField {
            res.text = "0"
        } else {
            for noRes in view.subviews {
                if let res = noRes as? UITextField {
                    res.text = "0"
                }
            }
        }
    }
    
    /// 弹窗
    func alert(_ sting: String) {
        let alert = UIAlertController(title: sting, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "✍️ 好吧", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func registerTFs() {
        self.view.endEditing(true)
    }
    
    private func dispose() {
        print("miaomiaomiao???")
    }
    
    private func setButtonTitleColorHighlight(btn : UIButton) {
        switch btn {
        case self.calculeTimeButton:
            self.calculeTimeButton.setTitleColor(UIColor.systemOrange, for: .normal)
            self.calculeDistanceButton.setTitleColor(UIColor.white, for: .normal)
            self.calculeSpeedButton.setTitleColor(UIColor.white, for: .normal)
            self.cleanButton.setTitleColor(UIColor.white, for: .normal)
            
        case self.calculeDistanceButton:
            self.calculeTimeButton.setTitleColor(UIColor.white, for: .normal)
            self.calculeDistanceButton.setTitleColor(UIColor.systemOrange, for: .normal)
            self.calculeSpeedButton.setTitleColor(UIColor.white, for: .normal)
            self.cleanButton.setTitleColor(UIColor.white, for: .normal)
            
        case self.calculeSpeedButton:
            self.calculeTimeButton.setTitleColor(UIColor.white, for: .normal)
            self.calculeDistanceButton.setTitleColor(UIColor.white, for: .normal)
            self.calculeSpeedButton.setTitleColor(UIColor.systemOrange, for: .normal)
            self.cleanButton.setTitleColor(UIColor.white, for: .normal)
            
        case self.cleanButton:
            self.calculeTimeButton.setTitleColor(UIColor.white, for: .normal)
            self.calculeDistanceButton.setTitleColor(UIColor.white, for: .normal)
            self.calculeSpeedButton.setTitleColor(UIColor.white, for: .normal)
            self.cleanButton.setTitleColor(UIColor.systemOrange, for: .normal)
            
        default: break
            
        }
    }
}

