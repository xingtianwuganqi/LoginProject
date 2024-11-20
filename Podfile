source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'

target 'LoginProject' do
  use_frameworks!
  pod 'BasicProject', :path=>'./../iOS_BasicProject'

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
       end
    end
  end
end
