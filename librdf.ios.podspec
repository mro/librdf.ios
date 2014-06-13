#
# Be sure to run `pod lib lint librdf.ios.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name              = "librdf.ios"
  s.version           = File.read('VERSION')
  s.summary           = "iOS linkable https://github.com/dajobe/librdf."
  s.homepage          = "http://purl.mro.name/ios/librdf"
  s.license           = 'Human Rights License'
  s.author            = { "Marcus Rohrmoser" => "mrohrmoser@acm.org" }
  s.source            = { :git => "https://github.com/mro/librdf.ios.git", :tag => s.version.to_s }

  s.platform          = :ios
  s.ios.deployment_target = '5.0'

  s.requires_arc      = false

  s.public_header_files = 'build/iOS-armv7s/include/**/*.h'

  s.libraries = 'xml2', 'sqlite3'
end
