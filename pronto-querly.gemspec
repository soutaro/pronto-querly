
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pronto/querly/version"

Gem::Specification.new do |spec|
  spec.name          = "pronto-querly"
  spec.version       = ProntoQuerly::VERSION
  spec.authors       = ["Soutaro Matsumoto"]
  spec.email         = ["matsumoto@soutaro.com"]

  spec.summary       = "Pronto runner for Querly"
  spec.description   = "Pronto runner for Querly"
  spec.homepage      = "https://github.com/soutaro/pronto-querly"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "pronto", "~> 0.9.5"
  spec.add_runtime_dependency "querly", "~> 0.11.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
