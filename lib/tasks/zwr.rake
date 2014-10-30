namespace :zwr do
  puts "looking for #{File.dirname( __FILE__ ) + '/../../assets'}"
  ASSETS_FOLDER = File.realpath( File.dirname( __FILE__ ) + '/../../assets')
  
  desc "installs zwr gem and features into a new app"
  task :install do
    puts "placing default favicon"
    FileUtils.cp "#{ASSETS_FOLDER}/favicon.ico", Rails.root.join('public')
    
    puts "removing turbolinks"
    #`sed -e s/deletethis//g -i #{Rails.root.join('Gemfile')}`
  end
end