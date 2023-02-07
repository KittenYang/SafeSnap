source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

def common_pod
  
  pod 'Moya/RxSwift', '~> 14.0'
  pod 'RxSwift', '5.1.1'
  pod 'RxCocoa', '5.1.1'
  pod 'BiometricAuthentication', '3.1.3'
  pod 'HandyJSON', '~> 5.0.2'
  pod 'KeychainAccess', '4.2.2'
  
  #  pod 'BigInt', :git => 'https://github.com/attaswift/BigInt.git', :branch => 'master'
  #  pod 'web3swift', :git => 'https://github.com/KittenYang/web3swift.git', :branch => 'develop'
  #  pod 'Web3Core', :git => 'https://github.com/KittenYang/web3swift.git', :branch => 'develop'
  pod 'BigInt', '~> 5.2.0'
  pod 'CryptoSwift', '~> 1.5.1'
  pod 'YYDispatchQueuePool'
  pod 'YYCategories'
  
  # Github Pods
  pod 'web3swift', :git => 'https://github.com/KittenYang/web3swift.git', :branch => 'feature/2.6.6/goerli'
  pod 'Defaults', :git => 'https://github.com/KittenYang/Defaults.git', :branch => 'develop'
  pod 'SwiftUIOverlayContainer', :git => 'https://github.com/KittenYang/SwiftUIOverlayContainer.git', :branch => 'main'
  
  # DevPods
  pod 'NetworkKit', :path => 'DevPods/NetworkKit'
  pod 'Refresh', :path => 'DevPods/Refresh'
  pod 'LanguageManagerSwiftUI', :path => 'DevPods/LanguageManagerSwiftUI'
  pod 'SheetKit', :path => 'DevPods/SheetKit'
  pod 'AlscCodableJSON', :path => 'DevPods/AlscCodableJSON'
  pod 'GnosisSafeKit', :path => 'DevPods/GnosisSafeKit'
  pod 'MultiSigKit', :path => 'DevPods/MultiSigKit'
  pod 'Introspect', :path => 'DevPods/Introspect'
  
end

target 'family-dao' do
  
  use_frameworks!
  
  common_pod
  
  target 'family-daoTests' do
    inherit! :search_paths
  end
  
  target 'family-daoUITests' do
    inherit! :search_paths
  end
  
end



post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # XCode14 编译要求bundle签名了
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
end

