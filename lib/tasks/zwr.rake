require 'active_support'
require 'active_support/core_ext'
require 'rake'
#require 'rails/generators'

class Pathname
  def remove_line(line)
    insert(text: "", instead_of: line)
  end
  
  # Will insert LINES after or instead of the LINE that matches given argument
  def insert(text: nil, after: nil, instead_of: nil, before: nil,  for_each_line: false)
    raise "You must specify text: argument or give a block that will preform the writing" unless text or block_given?
    raise "You cannot specify both after: and instead_of: arguments. Pick one." if after and instead_of
    raise "You cannot specify both after: and before: arguments. Pick one." if after and before
    raise "You cannot specify both instead_of: and before: arguments. Pick one." if instead_of and before
    if after || instead_of || before
      content = File.read(self)
      File.open(self, "w") do |file|
        content.lines.each do |line|
          if line.match(after || instead_of || before)
            file.puts line if after
            if text 
              file.puts text if text != ""
            else
              yield file, line
            end
            file.puts line if before
          else
            file.puts line
          end
        end
      end
    else
      File.open(self, "a") do |file|
        if text 
          file.puts text
        else
          yield file
        end
      end
    end
  end
end

namespace :zwr do
  desc "installs zwr gem and features into a new app"
  task :install do
    projectname = Rails.root.basename.to_s
    puts "placing default favicon"
    FileUtils.cp "#{File.dirname( __FILE__ )}/../../app/assets/images/favicon.ico", Rails.root.join('public')
    File.delete Rails.root.join('app/views/layouts/application.html.erb')
    File.write(Rails.root.join('app/views/layouts/application.html.haml'),<<-FILE_CONTENT.strip_heredoc)
        !!!
        %html
          %head
            %title #{projectname.capitalize}
            %meta(name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0")
            -# android stand alone mode
            %meta(name="mobile-web-app-capable" content="yes")
            %link(rel="icon" sizes="192x192" href="/assets/icon.png")
            -# iOS stand alone mode
            %meta(name="apple-mobile-web-app-capable" content="yes")
            %meta(name="apple-mobile-web-app-status-bar-style" content="black")
            %link(rel="apple-touch-icon" href="/assets/icon.png")
            %link(rel="apple-touch-startup-image" href="/assets/icon.png")
            -# windows 8.1, maybe mobile, maybe not
            %meta(name="application-name" content="ID Pickup")
            %meta(name="msapplication-navbutton-color" content="#FF3300")
            %meta(name="msapplication-square150x150logo" content="assets/icon.png")
            %meta(name="msapplication-square310x310logo" content="assets/icon.png")
            %meta(name="msapplication-square70x70logo" content="assets/icon.png")
            %meta(name="msapplication-wide310x150logo" content="assets/icon.png")
            %meta(name="msapplication-TileColor" content="#FF3300")
            %meta(name="msapplication-TileImage" content="assets/icon.png")
            %meta(name="msapplication-tooltip" content="ID Pickup")
            = stylesheet_link_tag    'application', media: 'all'
            = javascript_include_tag 'application'
            = csrf_meta_tags
          %body
            .container
              %nav.navbar.navbar-static-top.navbar-inverse(role="navigation")
                .container-fluid
                  -# Title
                  .navbar-header.pull-left
                    %a.navbar-brand(href="#")
                      =image_tag "logo.png", height: '20'
                      #{projectname.capitalize}
                  -# Sticky menu, on the right
                  #navbar-steady.navbar-header.pull-right
                    %ul.nav.navbar-nav.pull-left
                      -# Static menu items
                      %li.pull-left.hidden-xs
                        %a(href="#") Static 1
                      -# notice that the first to pull right will be right most!
                      %li.pull-right
                        %a(href="#") Static 2
                      -# Static text, like the username
                      %li.navbar-text.pull-right
                        %span.hidden-xs Welcome, 
                        %span guest
                    -# following button should ALWAYS be there, unless there is no colapsable items
                    %button.navbar-toggle.collapsed(type="button" data-toggle="collapse" data-target=".navbar-collapse" aria-expanded="false" aria-controls="navbar")
                      %span.sr-only Toggle navigation
                      %span.icon-bar
                      %span.icon-bar
                      %span.icon-bar
                  #navbar.navbar-collapse.collapse
                    %ul.nav.navbar-nav
                      %li.active
                        %a(href="#") Left 1
                      %li
                        %a(href="#") Left 2
                      %li
                        %a.dropdown-toggle(href="#" data-toggle="dropdown")
                          Drop
                          %span.caret
                        %ul.dropdown-menu(role="menu")
                          %li.dropdown-header Header for submenu group
                          %li
                            %a(href="#") Submenu 1
                          %li
                            %a(href="#") Submenu 2
                          %li
                            %a(href="#") Submenu 3
                          %li.divider
                          %li.dropdown-header Header for others
                          %li
                            %a(href="#") Submenu 4
                          %li
                            %a(href="#") Submenu 5
                    %ul.nav.navbar-nav.navbar-right
                      %li
                        %a(href="#") Right 1
                      %li
                        %a(href="#") Right 2
              .alert.alert-success(role="alert")=success_notice
              .alert.alert-info(role="alert")=notice
              .alert.alert-warning(role="alert")=alert_warning
              .alert.alert-danger(role="alert")=alert
              = yield
      FILE_CONTENT
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
        *= require_self
        */
        @import "bootstrap-sprockets";
        @import "bootstrap";
        @import "zwr";
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
  desc "creates user scaffod and devise object"
  task :user do
    #Rails::Generators.invoke("devise:install")
    puts `rails g devise:install`
    #Rails::Generators.invoke("scaffold",["User", "name:string","email:string",
    #                                     "password:string","password_confirmation:string", 
    #                                     "admin:boolean"])
    puts `rails g scaffold User name:string email:string password:string password_confirmation:string admin:boolean`
    puts "Removing app/models/user.rb"
    File.delete Rails.root.join('app/models/user.rb')
    puts "Renaming test/models/user_test.rb to test/models/user_test_orig.rb"
    File.rename Rails.root.join('test/models/user_test.rb'), Rails.root.join('test/models/user_test_orig.rb')
    puts "Removing test/factories/users.rb"
    File.delete Rails.root.join('test/factories/users.rb')
    #Rails::Generators.invoke("devise", ["User"])
    puts `rails g devise User`
    Rails.root.join("Gemfile").insert text: "gem 'bootstrap_form'"
    Rails.root.join("app/assets/stylesheets/application.css.scss").insert text: '@import "rails_bootstrap_forms";'
    Rails.root.join("app/models/user.rb").insert after: "field :encrypted_password" do |file|
      file.puts '  field :name,               type: String, default: ""'
      file.puts '  field :admin,              type: Boolean, default: ""'
    end
    Rails.root.join("app/views/layouts/application.html.haml").insert before: "= yield" do |file|
      file.puts '      - if notice'
      file.puts '        .alert.alert-info(role="alert")=notice'
      file.puts '      - if alert'
      file.puts '        .alert.alert-danger(role="alert")=alert'
    end
    Rails.root.join("app/views/users/_form.html.haml").insert text: "= bootstrap_form_for @user do |f|",
                                                              instead_of: "form_for @user do"
    Rails.root.join("app/views/users/_form.html.haml").insert text: "    #error_explanation.alert.alert-danger",
                                                              instead_of: "error_explanation"
    Rails.root.join("app/views/users/_form.html.haml").insert text: "    = f.password_field :password_confirmation",
                                                              instead_of: "f.text_field :password_confirmation"
    Rails.root.join("app/views/users/_form.html.haml").insert text: "    = f.password_field :password",
                                                              instead_of: "f.text_field :password"
    Rails.root.join("app/views/users/_form.html.haml").remove_line "f.label :name"
    Rails.root.join("app/views/users/_form.html.haml").remove_line "f.label :email"
    Rails.root.join("app/views/users/_form.html.haml").remove_line "f.label :password"
    Rails.root.join("app/views/users/_form.html.haml").remove_line "f.label :password_confirmation"
    Rails.root.join("app/views/users/_form.html.haml").remove_line "f.label :admin"
    Rails.root.join("config/routes.rb").insert instead_of: "resources :users" do |file|
      file.puts "  scope '/admin' do"
      file.puts "    resources :users, as: 'users'"
      file.puts "  end"
    end
    puts `bundle install`
    puts `git add -A`
    puts `git commit -sm "rake zwr:user"`
    puts `prax restart`
  end
end