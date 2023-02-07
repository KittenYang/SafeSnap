Pod::Spec.new do |s|
  s.name = 'SheetKit'
  s.version = '0.0.1'
  s.summary = 'SheetKit'
  s.description  = <<-DESC
  commit:${commit}
  DESC
  s.license = 'MIT'
  s.homepage = 'https://github.com/KittenYang/SheetKit'
  s.source = { :git => 'https://github.com/KittenYang/SheetKit.git', :tag => "#{s.version}" }
  s.authors = { 'KittenYang' => 'imkittenyang@gmail.com' }
  s.source_files = 'Sources/**/*.{h,m,swift}'
  s.exclude_files = ['Resources/SheetKit.bundle/Info.plist']
  s.platform     = :ios
  
  s.ios.deployment_target = '15.0'
  
  s.dependency  'Moya/RxSwift'
  s.dependency  'RxSwift'
  s.dependency  'RxCocoa'
  s.dependency  'HandyJSON'

end
