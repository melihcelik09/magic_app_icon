#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint magic_app_icon.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'magic_app_icon'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin to dynamically change app icons on iOS and Android platforms.'
  s.description      = <<-DESC
A Flutter plugin that allows you to dynamically change app icons on iOS and Android platforms with automatic icon generation.
                       DESC
  s.homepage         = 'https://github.com/yourusername/magic_app_icon'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end 