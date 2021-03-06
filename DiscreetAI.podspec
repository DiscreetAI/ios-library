#
# Be sure to run `pod lib lint DiscreetAI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DiscreetAI'
  s.version          = '1.0.4'
  s.summary          = 'Discreet AI\'s custom library for private on device training.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/DiscreetAI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'neeleshdodda44' => 'neelesh.dodda@discreetai.com' }
  s.source           = { :git => 'https://github.com/DiscreetAI/ios-library.git', :tag => s.version.to_s}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.4'

  s.source_files = 'DiscreetAI/**/*.swift'
  
  s.resource_bundles = {
    'DiscreetAI' => ['Datasets/**/*']
  }

  s.dependency 'RealmSwift', '>= 0.92.3'
  s.dependency 'Starscream', '~> 4.0.0'
  s.dependency 'Surge', '>= 2.3.0' 

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
