Pod::Spec.new do |s|
  s.name         = "HarvestAPI"
  s.version      = "0.1"
  s.summary      = ""
  s.description  = <<-DESC
    Your description here.
  DESC
  s.homepage     = "https://github.com/NicholasTD07/HarvestAPI.swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Nicholas T." => "Nicholas.TD07@gmail.com" }
  s.social_media_url   = ""
  s.module_name = s.name.to_s
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/NicholasTD07/HarvestAPI.swift.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"

  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'Result', '~> 3.0.0'
end
