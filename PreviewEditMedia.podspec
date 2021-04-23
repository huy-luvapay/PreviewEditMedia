#
# Be sure to run `pod lib lint PreviewEditMedia.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PreviewEditMedia'
  s.version          = '0.1.3'
  s.summary          = 'A short description of PreviewEditMedia.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/huy-luvapay/PreviewEditMedia'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huy-luvapay' => 'huy.van@epapersmart.com' }
  s.source           = { :git => 'https://github.com/huy-luvapay/PreviewEditMedia.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.swift_version = '5.0'

  s.source_files = 'PreviewEditMedia/Classes/**/*.{h,m,mm,swift}'
  
  s.resources = [
    'PreviewEditMedia/Assets/**/*.png',
    'PreviewEditMedia/Classes/**/*.bundle',
    'PreviewEditMedia/Classes/**/*.xib',
    'PreviewEditMedia/Classes/**/*.storyboard',
    "PreviewEditMedia/Assets/**/*.lproj"
  ]
  
  # s.resource_bundles = {
  #   'PreviewEditMedia' => ['PreviewEditMedia/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
