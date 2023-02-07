Pod::Spec.new do |s|
  s.name = 'LanguageManagerSwiftUI'
  s.version = '0.0.1'
  s.summary = 'LanguageManagerSwiftUI'
  s.description  = <<-DESC
  commit:${commit}
  DESC
  s.license = 'MIT'
  s.homepage = 'https://github.com/KittenYang/LanguageManagerSwiftUI'
  s.source = { :git => 'https://github.com/KittenYang/LanguageManagerSwiftUI.git', :tag => "#{s.version}" }
  s.authors = { 'KittenYang' => 'imkittenyang@gmail.com' }
  s.source_files = 'Sources/**/*.{h,m,swift}'
  s.exclude_files = ['Resources/LanguageManagerSwiftUI.bundle/Info.plist']
  s.platform     = :ios
  s.ios.deployment_target = '14.0'

end
