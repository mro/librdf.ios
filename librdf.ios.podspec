#
# Be sure to run `pod lib lint librdf.ios.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name              = "librdf.ios"
  s.version           = File.read('VERSION')
  s.summary           = "Redland RDF API and triple stores from https://github.com/dajobe/librdf for iOS."
  s.description       = <<-DESC
                        Brings the 3 libraries
                        
                        - raptor2: parsing and serializing RDF syntaxes,
                        - rasqal: executing RDF queries and
                        - redland:  RDF API and triple stores
                        
                        from http://librdf.org/
                      DESC
  s.homepage          = 'http://purl.mro.name/ios/librdf'
  s.license           = 'Human Rights License'
  s.author            = { "Marcus Rohrmoser" => "mrohrmoser@acm.org" }
  s.source            = { :git => "https://github.com/mro/librdf.ios.git", :tag => s.version.to_s }
  s.documentation_url = 'http://librdf.org/docs/'
  # todo: http://guides.cocoapods.org/syntax/podspec.html#docset_url

  s.platform          = :ios
  s.ios.deployment_target = '5.0'

  # https://github.com/CocoaPods/CocoaPods/issues/2249#issuecomment-46001518
  s.prepare_command   = 'bash build.sh all'
  s.xcconfig          = { 'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/build"' }
  s.vendored_libraries = 'build/lib*.a'                     # seems mandatory
  s.source_files      = 'build/iOS-armv7s/include/**/*.h'   # maybe obsolete
  s.preserve_paths    = 'build/lib*.a'                      # maybe obsolete

  s.public_header_files = 'build/iOS-armv7s/include/**/*.h'

  s.libraries         = 'xml2', 'xslt', 'sqlite3'
  s.requires_arc      = false
end
