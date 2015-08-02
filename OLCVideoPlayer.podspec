#
# Be sure to run `pod lib lint OLCVideoPlayer.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "OLCVideoPlayer"
  s.version          = "1.0.0"
  s.summary          = "Objective-C custom video player"
  s.description      = <<-DESC
OLCVideoPlayer is a custom video player that can do so much more than what the default MediaPlayer can do. The motivation behind this project was to make a video player that we have full controll over, so it has the ability to change play a collection of videos, change volume level, play in background, set time limits per video, smooth playback and so much more !

Full tutorail: https://onelonecoder.wordpress.com/2015/08/02/objective-c-custom-video-player/
DESC

  s.homepage         = "https://github.com/LakithaRav/OLCVideoPlayer"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Lakitha Sam" => "lakitharav@gmail.com" }
  s.source           = { :git => "https://github.com/LakithaRav/OLCVideoPlayer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/LakySam'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'OLCVideoPlayer' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
