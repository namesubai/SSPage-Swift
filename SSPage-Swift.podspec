#
#  Be sure to run `pod spec lint SSPageViewController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/

Pod::Spec.new do |spec|
spec.name         = "SSPage-Swift"
spec.version      = "1.0.18"
spec.summary      = "使用UIPageViewController实现的简单易用的界面切换组件"
spec.description  = <<-DESC
使用UIPageViewController实现的简单易用的界面切换组件
DESC
spec.swift_versions = "5.0"
spec.homepage     = "https://github.com/namesubai/SSPage-Swift.git"
spec.license      = "MIT"
spec.author             = { "subai" => "804663401@qq.com" }
spec.platform     = :ios, "9.0"
spec.source       = { :git => "https://github.com/namesubai/SSPage-Swift.git", :tag => "#{spec.version}"}
spec.source_files  = "Sources/Page/*.{swift,h,m}"

end
