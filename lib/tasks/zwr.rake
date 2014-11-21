require 'active_support'
require 'active_support/core_ext'
require 'rake'

namespace :zwr do
  desc "installs icon and other details into the new app."
  task :install do
    projectname = Rails.root.basename.to_s
    puts "      \033[35mcreate\033[0m    public/favicon.ico"
    FileUtils.cp "#{File.dirname( __FILE__ )}/../../app/assets/images/favicon.ico", Rails.root.join('public')
    
    `sed '/turbolinks/d' -i Gemfile`
    `sed "s/# gem 'theruby/gem 'theruby/" -i Gemfile`
  end

  namespace :production do
    desc "updates production environment to latest production branch"
    task :update do
      `git fetch`
      `git checkout production -q`
      `git reset --hard origin/production`
      `touch tmp/restart.txt`
      puts "now with the latest code from origin/production."
      puts "server restarted."
    end
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
      `git checkout master`
    end
  end
end