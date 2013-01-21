require "./lib/batch"

Gem::Specification.new do |s|
  s.name              = "batch"
  s.version           = Batch::VERSION
  s.summary           = "Iterate Enumerables with progress reporting."
  s.authors           = ["Damian Janowski", "Michel Martens"]
  s.email             = ["djanowski@dimaion.com", "michel@soveran.com"]
  s.homepage          = "http://github.com/djanowski/batch"
  s.files = `git ls-files`.split("\n")
end
