module Zwr
  module Angular
    class TemplateGenerator < Rails::Generators::NamedBase
      def copy_files
        create_file "app/assets/javascripts/templates/#{file_name.gsub("_","-")}.html.haml"
      end
    end
  end
end
