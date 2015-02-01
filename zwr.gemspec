Gem::Specification.new do |s|
  s.name        = 'zwr'
  s.version     = '0.1.7'
  s.date        = '2015-01-06'
  s.summary     = "All the Zwr needs"
  s.description = "the livings that fiteth for a gorge bellum."
  s.author      = "Zeljko"
  s.email       = 'zeljko@zwr.fi'
  s.files       = `git ls-files`.split("\n") - %w(.rvmrc .gitignore)
  s.executables = ["zwr"]
  s.homepage    = 'http://rubygems.org/gems/zwr'
  s.license       = 'MIT'

  s.add_dependency "railties", "~> 4.0", ">= 3.1"
end
