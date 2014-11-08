Gem::Specification.new do |s|
  s.name        = 'zwr'
  s.version     = '0.0.4'
  s.date        = '2014-10-26'
  s.summary     = "All the Zwr needs"
  s.description = "A gem in which I jam what I commonly use."
  s.authors     = ["Zeljko"]
  s.email       = 'zeljko@zwr.fi'
  s.files       = `git ls-files`.split("\n") - %w(.rvmrc .gitignore)
  s.executables = ["zwr"]
  s.homepage    = 'http://rubygems.org/gems/zwr'
  s.license       = 'MIT'
end