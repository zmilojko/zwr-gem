module Zwr
  module Angular
    class IncludeGenerator < Rails::Generators::NamedBase
      def copy_files
        create_file "app/assets/javascripts/includes/#{file_name.gsub("_","-")}.js.coffee"
      end
    end
  end
end
