module Zwr
  module Angular
    class PageGenerator < Rails::Generators::NamedBase
      def copy_files
        ang_file_name = file_name.gsub("_","-")
        dir_class = file_name.gsub("-","_").camelize(:lower)
        create_file "app/assets/javascripts/templates/#{ang_file_name}.html.haml"
        create_file "app/assets/javascripts/controllers/#{ang_file_name}.js.coffee", <<-FILE.strip_heredoc
          @#{application_name}.controller '#{dir_class}', [
            '$scope', '$routeParams', '$location', '$window', '$timeout',
            ($scope, $routeParams, $location, $window, $timeout) ->
              $scope.item = null
              $scope.error_message = null
              $scope.something = ->
                boo
              service.init(decodeURIComponent($routeParams.tagName))
              .then($scope._rememberItem,$scope._errorHandler)
          FILE
      end
    end
  end
end
