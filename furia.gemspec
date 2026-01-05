$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "furia/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "furia"
  s.version     = Furia::VERSION
  s.authors     = ["Viacheslav Alekseev"]
  s.email       = ["alexeev.corp@gmail.com"]
  s.homepage    = "https://github.com/alexeevit/furia"
  s.summary     = "SQL queries logger"
  s.description = "An app for logging and investigating SQL queries"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.11"
  s.add_dependency "jquery-rails"
end
