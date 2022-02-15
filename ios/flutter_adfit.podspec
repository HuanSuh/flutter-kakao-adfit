#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_adfit.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_adfit'
  s.version          = '0.0.2'
  s.summary          = 'AdFit package for Flutter.'
  s.description      = <<-DESC
  s.dependency 'AdFitSDK'

AdFit package for Flutter.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'AdFitSDK', '~> 3.11.1'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64' }
  s.swift_version = '5.0'
end
