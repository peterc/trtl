Gem::Specification.new do |s|
  s.name        = "trtl"
  s.version     = "0.1.0"
  s.authors     = ["Peter Cooper"]
  s.email       = ["git@peterc.org"]
  s.homepage    = "https://github.com/peterc/trtl"
  s.license     = "MIT"
  s.summary     = %q{Ruby turtle graphics (ideal for use from IRB)}
  s.description = %q{A Logo / turtle.py style turtle graphics system for Ruby}

  s.required_ruby_version = ">= 2.6"

  s.files         = `git ls-files -- lib examples README.md LICENSE.md`.split("\n")
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'libui', '~> 0.2'
end
