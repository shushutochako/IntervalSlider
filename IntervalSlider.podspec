Pod::Spec.new do |s|
  s.name             = "IntervalSlider"
  s.version          = "0.0.1"
  s.summary          = "IntervalSlider is a slider library like ReutersTV app. written in pure swift."
  s.homepage         = "https://github.com/shushutochako/IntervalSlider"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "shushutochako" => "shushutochako22@gmail.com" }
  s.source           = { :git => "https://github.com/shushutochako/IntervalSlider.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/shushutochako'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
