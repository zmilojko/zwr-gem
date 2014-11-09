require 'active_support'
require 'active_support/core_ext'
require 'rake'

namespace :zwr do
  ASSETS_FOLDER = File.realpath( File.dirname( __FILE__ ) + '/../../assets')
  
  desc "installs zwr gem and features into a new app"
  task :install do
    puts "placing default favicon"
    FileUtils.cp "#{ASSETS_FOLDER}/favicon.ico", Rails.root.join('public')
    
    puts "removing turbolinks"
    `sed "s|, 'data-turbolinks-track' => true||" -i #{Rails.root.join('app/views/layouts/application.html.erb')}`
    `html2haml app/views/layouts/application.html.erb > app/views/layouts/application.html.haml`
    File.delete Rails.root.join('app/views/layouts/application.html.erb')
    File.delete Rails.root.join('app/assets/javascripts/application.js')
    File.write(Rails.root.join('app/assets/javascripts/app.js.coffee'), <<-FILE_CONTENT.strip_heredoc)
        #= require angular
        #= require angular-route
        #= require angular-resource
        #= require angular-rails-templates
        #= require_tree ./templates
        #= require main
        #= require_tree ./includes
        #= require_tree ./directives
        #= require_tree ./services
        #= require_tree ./controllers
        #= require angular-ui-bootstrap
      FILE_CONTENT
    File.write(Rails.root.join('app/assets/javascripts/application.js.coffee'),<<-FILE_CONTENT.strip_heredoc)
        #= require jquery
        #= require jquery_ujs
        #= require bootstrap-sprockets
      FILE_CONTENT
    File.delete Rails.root.join('app/assets/stylesheets/application.css')
    File.write(Rails.root.join('app/assets/stylesheets/application.css.scss'),<<-FILE_CONTENT.strip_heredoc)
      /*
       *= require_tree .
       *= require_self
       */
      @import "bootstrap-sprockets";
      @import "bootstrap";
      FILE_CONTENT
    File.write(Rails.root.join('db/seeds.rb'),<<-FILE_CONTENT.strip_heredoc)
      Dir[Rails.root.join('db/seeds/*.rb')].each { |file| load file }
      FILE_CONTENT
    Dir.mkdir Rails.root.join('db/seeds')
    File.write(Rails.root.join('config/initializers/markdown.rb'),<<-FILE_CONTENT.strip_heredoc)
      # Initializes a Markdown parser
      Markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
      FILE_CONTENT
  end
              
  desc "prepares production branch ready to roll"
  task :prepare do
    Dir.chdir Rails.root
    git_status = `git status`
    unless git_status.downcase.include?("on branch master") && 
        git_status.downcase.include?("nothing to commit, working directory clean")
      puts "Commit all changes and make sure you are on the master branch."
    else
      branches = `git branch`
      unless branches.include?("production")
        `sed "s|serve_static_assets = false|serve_static_assets = true|" -i #{Rails.root.join('config/environments/production.rb')}`
        `sed "s/.*# config.secret_key.*/  config.secret_key = '#{SecureRandom.hex(64)}'/" -i  #{Rails.root.join('config/initializers/devise.rb')}`
        `sed 's|... ENV..SECRET_KEY_BASE.. ..|#{SecureRandom.hex(64)}|' -i #{Rails.root.join('config/secrets.yml')}`
        `git commit -asm "zwr deployment modifications"`
        `chmod 777 tmp -R`
        `chmod 777 log`
        `chmod 777 db`
        `git branch production`
        `git checkout production`
      else
        `git checkout production`
        `git reset --hard master`
      end
      Rails.env = "production"
      Rake::Task["assets:precompile"].reenable
      Rake::Task["assets:precompile"].invoke
      `git add -A`
      `git commit -asm "precompiled resources"`
      `git push -u origin master`
      `git push -uf origin production`
    end
  end
end