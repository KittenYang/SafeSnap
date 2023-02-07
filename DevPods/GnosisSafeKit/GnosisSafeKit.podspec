

Pod::Spec.new do |s|
	s.name = 'GnosisSafeKit'
	s.version = '0.0.1'
	s.summary = 'GnosisSafeKit'
  s.description  = <<-DESC
  commit:${commit}
  DESC
	s.license = 'MIT'
	s.homepage = 'https://github.com/KittenYang/GnosisSafeKit'
	s.source = { :git => 'https://github.com/KittenYang/GnosisSafeKit.git', :tag => "#{s.version}" }
	s.authors = { 'KittenYang' => 'imkittenyang@gmail.com' }
	s.source_files = 'Sources/**/*.{h,m,swift}'
  s.platform     = :ios
	s.ios.deployment_target = '14.0'

  s.dependency  'BigInt'
  s.dependency 'CryptoSwift'#, '1.5.1'

end
