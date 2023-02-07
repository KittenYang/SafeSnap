Pod::Spec.new do |s|
  s.name = 'NetworkKit'
  s.version = '0.0.1'
  s.summary = 'NetworkKit'
  s.description  = <<-DESC
  commit:${commit}
  DESC
  s.license = 'MIT'
  s.homepage = 'https://github.com/KittenYang/NetworkKit'
  s.source = { :git => 'https://github.com/KittenYang/NetworkKit.git', :tag => "#{s.version}" }
  s.authors = { 'KittenYang' => 'imkittenyang@gmail.com' }
  s.source_files = 'Sources/**/*.{h,m,swift}'
  s.exclude_files = ['Resources/NetworkKit.bundle/Info.plist']
  s.platform     = :ios
  s.ios.deployment_target = '14.0'

  s.dependency  'Moya/RxSwift'
  s.dependency  'RxSwift'
  s.dependency  'RxCocoa'
  s.dependency  'HandyJSON'

end
