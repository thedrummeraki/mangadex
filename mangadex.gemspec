
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mangadex/version"

Gem::Specification.new do |spec|
  spec.name          = "mangadex"
  spec.version       = Mangadex::Version::FULL
  spec.authors       = ["Akinyele Cafe-Febrissy"]
  spec.email         = ["me@akinyele.ca"]

  spec.summary       = "Your next favourite Ruby gem for interacting with Mangadex.org"
  spec.homepage      = "https://github.com/thedrummeraki/mangadex"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "psych", "~> 4.0.1"
  spec.add_dependency "rest-client", "~> 2.1"
  spec.add_dependency "activesupport", "~> 6.1"
  spec.add_dependency "sorbet-runtime"

  spec.add_development_dependency "bundler", "~> 2.2.19"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "sorbet"
end
