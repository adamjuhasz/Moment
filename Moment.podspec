#
# Be sure to run `pod lib lint Moment.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Moment"
  s.version          = "0.1.0"
  s.summary          = "A short description of Moment."
  s.description      = <<-DESC
                       An optional longer description of Moment

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/Moment"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Adam Juhasz" => "adam@blaqlabs.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/Moment.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Moment' => ['Pod/Assets/leaks/*.jpg']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Mantle'
   s.dependency 'GPUImage'
   s.dependency 'CocoaLumberjack'
   s.dependency 'NYXImagesKit'
   s.dependency 'CocoaSecurity'
   s.dependency 'UICKeyChainStore'
   s.dependency 'ReactiveCocoa'
end
