require 'active_support'
require 'active_support/core_ext'

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
end