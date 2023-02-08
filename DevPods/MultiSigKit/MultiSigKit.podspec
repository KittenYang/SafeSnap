Pod::Spec.new do |s|
  s.name = 'MultiSigKit'
  s.version = '0.0.1'
  s.summary = 'MultiSigKit'
  s.description  = <<-DESC
  commit:${commit}
  DESC
  s.license = 'MIT'
  s.homepage = 'https://github.com/KittenYang/MultiSigKit'
  s.source = { :git => 'https://github.com/KittenYang/MultiSigKit.git', :tag => "#{s.version}" }
  s.authors = { 'KittenYang' => 'imkittenyang@gmail.com' }
  s.source_files = 'Sources/**/*.{h,m,swift}'
  s.exclude_files = ['Resources/MultiSigKit.bundle/Info.plist']
  s.platform     = :ios
  s.ios.deployment_target = '15.0'

  s.resources = '*.xcdatamodeld'
  s.dependency  'GnosisSafeKit'
  s.dependency  'NetworkKit'
  s.dependency  'SuperCodableJSON'
  s.dependency  'web3swift'
  s.dependency  'KeychainAccess'
  s.dependency  'Defaults'
  s.dependency  'BiometricAuthentication'
  s.dependency  'YYDispatchQueuePool'
  s.dependency  'LanguageManagerSwiftUI'
  s.dependency  'SwiftUIOverlayContainer'

  
end
