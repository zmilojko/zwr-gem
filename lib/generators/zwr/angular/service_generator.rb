module Zwr
  module Angular
    class ServiceGenerator < Rails::Generators::NamedBase
      def copy_files
        # we want all services to end with the word service. So add it, 
        # unless it is already there
        service_name = file_name.gsub(/[_-]service$/,"")
        ang_file_name = service_name.gsub("_","-")
        service_class = service_name.gsub("-","_").camelize(:lower) + "Service"
        create_file "app/assets/javascripts/directives/#{ang_file_name}.js.coffee", <<-FILE.strip_heredoc
          @#{application_name}.service '#{service_class}', [
            '$http', '$q', 'localStorageService',
            ($http, $q, identComm, localStorageService) -> 
              service =
                constructor: ->
                  @my_variable = null
                  service
                method: ->
                  me = this
                  $http.get('./my_var.json').then (server_response) ->
                    me.my_variable = server_response.data
                quick: ->
                  $q.when @my_variable
              service.constructor()
          ]
          FILE
      end
    end
  end
end
