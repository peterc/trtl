# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "trtl"

Gem::Specification.new do |s|
  s.name        = "trtl"
  s.version     = Trtl::VERSION
  s.authors     = ["Peter Cooper"]
  s.email       = ["git@peterc.org"]
  s.homepage    = "https://github.com/peterc/trtl"
  s.summary     = %q{Ruby turtle graphics (ideal for use from IRb)}
  s.description = %q{A Logo / turtle.py style turtle graphics system for Ruby}

  s.rubyforge_project = "trtl"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'tk', '~> 0.1'
end
