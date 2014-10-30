require 'active_support'
require 'active_support/core_ext'

namespace :zwr do
  puts "looking for #{File.dirname( __FILE__ ) + '/../../assets'}"
  ASSETS_FOLDER = File.realpath( File.dirname( __FILE__ ) + '/../../assets')
  
  desc "installs zwr gem and features into a new app"
  task :install do
    puts "placing default favicon"
    FileUtils.cp "#{ASSETS_FOLDER}/favicon.ico", Rails.root.join('public')
    
    puts "removing turbolinks"
    `sed "s|, 'data-turbolinks-track' => true||" -i #{Rails.root.join('app/views/layouts/application.html.erb')}`
    `html2haml app/views/layouts/application.html.erb > app/views/layouts/application.html.haml`
    `rm app/views/layouts/application.html.erb`
    `rm app/assets/javascripts/application.js`
    new_js_manifest =  <<-JS_FILE.strip_heredoc
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
      JS_FILE
    `echo '#{new_js_manifest}' > app/assets/javascripts/app.js.coffee`
    new_js_manifest2 =  <<-JS_FILE.strip_heredoc
        #= require jquery
        #= require jquery_ujs
        #= require bootstrap-sprockets
    `echo '#{new_js_manifest}' > app/assets/javascripts/application.js.coffee`

    `rm app/assets/stylesheets/application.css`
    new_css_manifest =  <<-CSS_FILE.strip_heredoc
      /*
       *= require_tree .
       *= require_self
       */
      @import "bootstrap-sprockets";
      @import "bootstrap";
      CSS_FILE
    `echo '#{new_css_manifest}' > app/assets/stylesheets/application.css.scss`
  end
end