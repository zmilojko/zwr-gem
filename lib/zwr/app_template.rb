puts "         \033[35mzwr\033[0m  Now applying ZWR template."
puts "         \033[35mapp\033[0m  #{@app_name}."
puts "        \033[35margs\033[0m  #{@args.join ", "}."

def tpl(filename)
  File.read(File.expand_path("../templates/#{filename}", __FILE__))
    .gsub("APP_NAME",@app_name)
end

use_angular = @args.include? 'use-angular'
use_mongoid = @args.include? 'use-mongoid'
use_devise = @args.include? 'use-devise'

gem 'zwr'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'bootstrap_form'
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

gem 'redcarpet'
gem 'paperclip'
gem 'html2haml'

if use_mongoid
  gem 'mongoid', '~> 4.0.0',github: 'mongoid/mongoid'
  gem 'bson_ext'
  run 'bundle install --quiet'
  generate 'mongoid:config'
end

gem 'factory_girl_rails', '~> 4.0'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
gem 'tzinfo', platforms: [:mingw, :mswin, :x64_mingw]

if use_devise
  gem 'devise', '~> 3.3.0'
  generate 'devise:install'
  generate :scaffold, 'User', 'name:string', 'email:string', 
    'password:string', 'password_confirmation:string', 'admin:boolean'
  remove_file 'app/models/user.rb'
  run 'cp test/models/user_test.rb test/models/user_test_orig.rb'
  remove_file 'test/models/user_test.rb'
  remove_file 'test/factories/users.rb'
  remove_file 'test/fixtures/users.yml'
  run 'rm -f db/migrate/*_create_users.rb'
  generate :devise, 'User'
  if use_mongoid
    inject_into_file  'app/models/user.rb', <<-FILE.strip_heredoc, before: "## Database authenticatable\n"
      ## ZWR generated fields
        field :name,               type: String, default: ""
        field :admin,              type: Boolean, default: false

      FILE
    gsub_file  'app/models/user.rb', "## Database authenticatable", "  ## Database authenticatable"
    gsub_file "test/test_helper.rb","# Add more helper methods to be used by all tests here...", 
      "include FactoryGirl::Syntax::Methods"
  else
    filename = Dir.glob("db/migrate/*_devise_create_users.rb")[0]
    puts "       \033[35mfound\033[0m  #{filename}"
    inject_into_file(filename, <<-FILE, :after => "Database authenticatable\n")
      t.string   :name
      t.boolean  :admin, default: false
    FILE
    gsub_file "test/test_helper.rb","fixtures :all", "include FactoryGirl::Syntax::Methods"
  end
  gsub_file "app/views/users/_form.html.haml","form_for @user do","bootstrap_form_for @user do"
  gsub_file "app/views/users/_form.html.haml","error_explanation","error_explanation.alert.alert-danger"
  gsub_file "app/views/users/_form.html.haml","f.text_field :password","f.password_field :password"
  gsub_file "app/views/users/_form.html.haml","= f.label :name",""
  gsub_file "app/views/users/_form.html.haml","= f.label :email",""
  gsub_file "app/views/users/_form.html.haml","= f.label :password_confirmation",""
  gsub_file "app/views/users/_form.html.haml","= f.label :password",""
  gsub_file "app/views/users/_form.html.haml","= f.label :admin",""
  gsub_file "config/routes.rb","resources :users", <<-FILE.strip_heredoc
    scope '/admin' do
        resources :users, as: 'users'
      end
    FILE
  inject_into_file  'test/factories/users.rb', <<-FILE.strip_heredoc, after: "factory :user do\n"
    email 'user@example.com'
    password '1234567890'
    password_confirmation '1234567890'
    FILE
  gsub_file "test/controllers/users_controller_test.rb","@user = users(:one)",
    "User.delete_all\n    @user = create(:user)"
  gsub_file "test/controllers/users_controller_test.rb","@user.email", '"xxx#{@user.email}"'
end

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

initializer 'zwr.rb', <<-FILE.strip_heredoc
  Markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  FILE

file 'db/seeds/.keep'



rake 'zwr:install'
rake 'db:migrate'

unless use_mongoid
  run 'bundle install --quiet'
end

# Git commands should be the last so that they catch all the files!
git init: '-q'
git add: '-A'
git commit: "-q -asm 'zwr new #{@app_name}'"
git remote: "add origin git@github.com:zmilojko/#{@app_name}.git"

