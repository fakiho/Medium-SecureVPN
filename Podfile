# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

# ignore all warnings from all pods
use_frameworks!
inhibit_all_warnings!

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
end

def uiBuilder
  pod 'SnapKit'
end

def rxSwift
  pod 'RxSwift', '6.0.0-rc.1'
  pod 'RxCocoa', '6.0.0-rc.1'
end

target 'Secure VPN' do
  # Comment the next line if you don't want to use dynamic frameworks
  # Pods for VPN Guard
  uiBuilder
  pod 'Google-Mobile-Ads-SDK', '7.69.0'
  pod "PlainPing"
  pod "BugShaker"
  pod 'SCLAlertView'
  pod 'SwiftyStoreKit'
end
