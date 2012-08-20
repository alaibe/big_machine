$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "big_machine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "big_machine"
  s.version     = BigMachine::VERSION
  s.authors     = ["Anthony Laibe"]
  s.email       = ["anthony.laibe@gmail.com"]
  s.homepage    = "https://github.com/alaibe/big_machine"
  s.summary     = "State machine for any ruby object"
  s.description = "Add support for creating state machine on any ruby object"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activesupport", "~> 3.2.8"
  s.add_dependency "rake"
end
