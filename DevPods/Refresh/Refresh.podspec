Pod::Spec.new do |s|
  s.name = 'Refresh'
  s.version = '0.0.1'
  s.summary = 'Refresh'
  s.description  = <<-DESC
  commit:${commit}
  DESC
  s.license = 'MIT'
  s.homepage = 'https://github.com/KittenYang/Refresh'
  s.source = { :git => 'https://github.com/KittenYang/Refresh.git', :tag => "#{s.version}" }
  s.authors = { 'KittenYang' => 'imkittenyang@gmail.com' }
  s.source_files = 'Sources/**/*.{h,m,swift}'
  s.exclude_files = ['Resources/Refresh.bundle/Info.plist']
  s.platform     = :ios
  s.ios.deployment_target = '14.0'

  s.dependency  'Moya/RxSwift'
  s.dependency  'RxSwift'
  s.dependency  'RxCocoa'
  s.dependency  'HandyJSON'

end
