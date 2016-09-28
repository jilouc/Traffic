#
#  Be sure to run `pod spec lint Traffic.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "Traffic"
  s.version      = "0.2.5"
  s.summary      = "Simple and powerful URL routing library to easily handle incoming URLs in your app."
  s.homepage     = "https://github.com/jilouc/Traffic"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "jldagon" => "jldagon@cocoapps.fr" }
  
  s.ios.deployment_target = "8.0"
  
  s.source       = { :git => "https://github.com/jilouc/Traffic.git", :tag => "#{s.version}" }

  s.source_files  = "Traffic", "Traffic/**/*.{h,m}", "Private/**/*.{h,m}"
  s.public_header_files = "Traffic/**/*.h"
  s.requires_arc = true

end
