Gem::Specification.new do |s|

  s.name                  = "site-inspector"
  s.version               = "0.1.0"
  s.summary               = "A Ruby port and v2 of Site Inspector (http://github.com/benbalter/site-inspector)"
  s.description           = "Returns information about a domain's technology and capabilities"
  s.authors               = "Ben Balter"
  s.email                 = "ben@balter.com"
  s.homepage              = "https://github.com/benbalter/site-inspector-ruby"
  s.license               = "MIT"
  s.files = [
    "lib/site-inspector.rb",
    "lib/data/cdn.yml",
    "lib/data/cloud.yml",
    "lib/site-inspector/cache.rb",
    "lib/site-inspector/compliance.rb",
    "lib/site-inspector/dns.rb",
    "lib/site-inspector/headers.rb",
    "lib/site-inspector/sniffer.rb",
    "LICENSE"
  ]
  s.add_dependency("nokogiri")
  s.add_dependency("public_suffix")
  s.add_dependency("gman")
  s.add_dependency("dnsruby")
  s.add_dependency("sniffles")
  s.add_dependency("typhoeus")
  s.add_development_dependency("pry")
  s.add_development_dependency( "rake" )
  s.add_development_dependency( "shoulda" )
  s.add_development_dependency( "rdoc" )
  s.add_development_dependency( "bundler" )
  s.add_development_dependency( "rerun" )
  s.add_development_dependency( "vcr" )
  s.add_development_dependency( "webmock" )
end
