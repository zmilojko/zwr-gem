puts "         \033[35mzwr\033[0m  Now applying ZWR template."
puts "         \033[35mapp\033[0m  #{@app_name}."
puts "        \033[35margs\033[0m  #{@args}."

def tpl(filename)
  File.read(File.expand_path("../templates/#{filename}", __FILE__))
    .gsub("APP_NAME",@app_name)
end

use_angular = @args.include? 'use-angular'
use_mongoid = @args.include? 'use-mongoid'
use_devise = @args.include? 'use-devise'

gem 'zwr'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'puma', platforms: :ruby
gem 'haml-rails'

if use_angular
  gem 'angularjs-rails'
  gem 'angular-rails-templates'
  gem 'angular-ui-bootstrap-rails'
  gem 'angular_rails_csrf'
  file 'app/assets/javascripts/controllers/.keep'
  file 'app/assets/javascripts/directives/.keep'
  file 'app/assets/javascripts/includes/.keep'
  file 'app/assets/javascripts/services/.keep'
  file 'app/assets/javascripts/templates/.keep'
  file 'app/assets/javascripts/app.js.coffee', tpl('app.js.coffee')
  file 'app/assets/javascripts/includes/angular-local-storage.js', 
    tpl('angular-local-storage.js')
  file 'app/assets/javascripts/templates/home.html.haml', 
    tpl('home.html.haml')
  file 'app/assets/javascripts/controllers/home_controller.js.coffee', 
    tpl('home_controller.js.coffee')
  file 'app/views/home/index.html.haml', tpl('index.html.haml')
  file 'app/controllers/home_controller.rb', tpl('home_controller.rb')
  append_file 'config/initializers/assets.rb',
    'Rails.application.config.assets.precompile += %w( app.js )'
  route "root to: 'home#index'"
end  

if use_devise
  gem 'devise', '~> 3.3.0'
end

gem 'redcarpet'
gem 'paperclip'
gem 'html2haml'

if use_mongoid
  gem 'mongoid', '~> 4.0.0',github: 'mongoid/mongoid'
  gem 'bson_ext'
  generate 'mongoid:config'
end

gem 'factory_girl_rails', '~> 4.0'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
gem 'tzinfo', platforms: [:mingw, :mswin, :x64_mingw]

remove_file 'README.rdoc' 
file 'README.markdown', 'Application #{ARGV[1]} generated bu the zwr generator.'

remove_file 'app/views/layouts/application.html.erb' 
file 'app/views/layouts/application.html.haml', tpl('application.html.haml') 

remove_file 'app/assets/javascripts/application.js'
file 'app/assets/javascripts/application.js.coffee', tpl('application.js.coffee') 

remove_file 'app/assets/stylesheets/application.css'
file 'app/assets/stylesheets/application.css.scss', tpl('application.css.scss') 

remove_file 'db/seeds.rb'
file 'db/seeds.rb', "Dir[Rails.root.join('db/seeds/*.rb')].each { |file| load file }"

initializer 'markdown.rb',
  'Markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)'

file 'db/seeds/.keep'



rake 'zwr:install'
rake 'db:migrate'

run 'bundle --quiet'

# Git commands should be the last so that they catch all the files!
git init: '-q'
git add: '-A'
git commit: "-q -asm 'zwr new #{@app_name}'"
git remote: "add origin git@github.com:zmilojko/#{@app_name}.git"

