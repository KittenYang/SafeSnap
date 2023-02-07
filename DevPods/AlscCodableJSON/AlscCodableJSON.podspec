Pod::Spec.new do |s|
  s.name = 'AlscCodableJSON'
  s.version = '0.0.1'
  s.summary = 'AlscCodableJSON'
  s.description  = <<-DESC
  commit:${commit}
  DESC
  s.license = 'MIT'
  s.homepage = 'https://github.com/KittenYang/AlscCodableJSON'
  s.source = { :git => 'https://github.com/KittenYang/AlscCodableJSON.git', :tag => "#{s.version}" }
  s.authors = { 'KittenYang' => 'imkittenyang@gmail.com' }
  s.source_files = 'Sources/**/*.{h,m,swift}'
  s.exclude_files = ['Resources/AlscCodableJSON.bundle/Info.plist']
  s.platform     = :ios
  s.ios.deployment_target = '9.0'

end

