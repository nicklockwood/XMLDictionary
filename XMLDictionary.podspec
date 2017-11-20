Pod::Spec.new do |s|
  s.name         = "XMLDictionary"
  s.version      = "1.5"
  s.license      = { :type => 'zlib', :file => 'LICENCE.md' }
  s.summary      = "XMLDictionary is a class designed to simplify parsing and generating of XML on iOS and Mac OS."
  s.homepage     = "https://github.com/BadChoice/XMLDictionary"
  s.authors      = "BadChoice" 
  s.source       = { :git => "https://github.com/BadChoice/XMLDictionary.git", :tag => "1.5" }
  s.source_files = 'XMLDictionary'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.6'
end
