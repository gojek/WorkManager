Pod::Spec.new do |s|
  s.name             = "WorkManager"
  s.version          = "0.9.0"
  s.summary          = "WorkManager is a periodic task scheduler "
  s.description      = "WorkMaanger shedules periodic task that get executed regardless of the app sessions"

  s.homepage         = 'https://github.com/gojek/WorkManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  
  s.author           = "Gojek"
  s.source           = { :git => 'https://github.com/gojek/WorkManager.git', :tag => '#{s.version}' }

  s.platform         = :ios
  s.ios.deployment_target = '11.0'
  s.swift_version    = '5.0'

  s.source_files  = 'Sources/WorkManager/*.swift'

end
