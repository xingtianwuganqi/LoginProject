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
  spec.swift_versions = ['5.8', '5.9']
  
  spec.author       = { "jingjun" => "rxswift@126.com" }
  
  spec.platform     = :ios, "13.0"

  spec.source       = { :git => "https://github.com/xingtianwuganqi/LoginProject.git", :tag => "#{spec.version}" }
  spec.source_files = "LoginProject/LoginPage/*.swift","LoginProject/LoginPage/**/*.swift"
  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  spec.resource_bundles = {
    'LoginProject' => ['LoginProject/LoginPage/ViewController/*.{xib}'],
    'LoginIconBundle' => ['LoginProject/LoginPage/Resources/*.bundle/*.png']
  }
  
  spec.frameworks   = ["Foundation","UIKit"]

  spec.dependency 'BasicProject'

end
