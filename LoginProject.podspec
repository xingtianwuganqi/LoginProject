#
#  Be sure to run `pod spec lint LoginProject.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "LoginProject"
  spec.version      = "0.0.1"
  spec.summary      = "ios Login demo"

  spec.description  = <<-DESC
  ios login demo,use for lovecat
                   DESC

  spec.homepage     = "https://github.com/xingtianwuganqi/LoginProject.git"

  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3']
  
  spec.author       = { "jingjun" => "rxswift@126.com" }
  
  spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/xingtianwuganqi/LoginProject.git", :tag => "#{spec.version}" }
  spec.source_files = "LoginProject/LoginPage/*.swift","LoginProject/LoginPage/**/*.swift"
  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  spec.resources = "LoginProject/LoginPage/ViewController/*.{xib}"
  
  spec.frameworks   = ["Foundation","UIKit"]

  spec.dependency 'BasicProject'
  
#  spec.ios.deployment_target = "11.0"


end
