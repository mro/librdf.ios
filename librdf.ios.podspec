#
# Be sure to run `pod lib lint librdf.ios.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "librdf.ios"
  s.version          = '1.0.17' # File.read('VERSION')
  s.summary          = "IOS linkable https://github.com/dajobe/librdf."
  s.homepage         = "http://purl.mro.name/ios/librdf"
  s.license          = 'Human Rights License'
  s.author           = { "Marcus Rohrmoser" => "mrohrmoser@acm.org" }
  s.source           = { :git => "https://github.com/mro/librdf.ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '5.0'
  s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = false

#  s.source_files = 'Classes'
#  s.resources = 'Assets/*.png'

#  s.ios.exclude_files = 'Classes/osx'
#  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'build/iOS-armv7s/include/**/*.h'
  
  s.vendored_libraries = 'build/lib*.a'
  
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  
  s.libraries = 'xml2', 'sqlite3'
  
  # s.dependency 'JSONKit', '~> 1.4'
end
