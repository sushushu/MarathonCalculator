# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'Speed' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Speed
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SnapKit'
  pod 'IQKeyboardManagerSwift'
  pod 'LookinServer'  , :configurations => ['Debug']
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'  # 或更高版本
      # 支持模拟器的架构设置
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
