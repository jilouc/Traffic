#
#  Be sure to run `pod spec lint Traffic.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "Traffic"
  s.version      = "0.6.1"
  s.summary      = "Simple and powerful URL routing library to easily handle incoming URLs in your app."
  s.homepage     = "https://github.com/jilouc/Traffic"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "jldagon" => "jldagon@cocoapps.fr" }
  
  s.ios.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
  
  s.source       = { :git => "https://github.com/jilouc/Traffic.git", :tag => "#{s.version}" }
  s.requires_arc = true

  pch_Traffic = <<-EOS
#ifndef TARGET_OS_IOS
  #define TARGET_OS_IOS TARGET_OS_IPHONE
#endif
#ifndef TARGET_OS_WATCH
  #define TARGET_OS_WATCH 0
#endif
#ifndef TARGET_OS_TV
  #define TARGET_OS_TV 0
#endif
EOS

  s.prefix_header_contents = pch_Traffic


  s.subspec 'Core' do |ss|
    ss.ios.deployment_target = "9.0"
    ss.watchos.deployment_target = "2.0"
    ss.source_files  = "Traffic/*.{h,m}", "Private/**/*.{h,m}"
    ss.public_header_files = "Traffic/*.h"
  end

  s.subspec 'UIKit' do |ss|
    ss.ios.deployment_target = "9.0"
    ss.source_files = 'Traffic/UIKit'
    ss.public_header_files = 'Traffic/UIKit/*.h'
    ss.dependency 'Traffic/Core'
  end


end
