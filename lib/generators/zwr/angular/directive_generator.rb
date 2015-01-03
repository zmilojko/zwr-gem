module Zwr
  module Angular
    class DirectiveGenerator < Rails::Generators::NamedBase
      def copy_files
        ang_file_name = file_name.gsub("_","-")
        dir_class = file_name.gsub("-","_").camelize(:lower)
        create_file "app/assets/javascripts/directives/#{ang_file_name}.js.coffee", <<-FILE.strip_heredoc
          @#{application_name}.directive '#{dir_class}', ['$timeout', ($timeout) ->
            ret =
              restrict: 'AE'      # also possible class C
              transclude: true    # set to false if ignoring content
              scope:
                cmd: '&#{dir_class}'    # isolate scope of a function, passed as a value 
                                        # of the attribute with the name of the directive
                disabled: '='     # isolate scope of a model (both ways), passed with an 
                                  # attribute disabled="XXX", where XXX is a variable of 
                                  # the scope
                glyph: '@'        # isolate scope of a variable (in only), passed with 
                                  # an attribute disabled="123"
              link: (scope, elem, attr) ->
                scope.$watch (scope) ->
                  scope.ztItem
                , ->
                  scope.revertLocal() if scope.ztItem
                scope.$watch () ->
                  element[0].focus() if scope.focusMe == 'true'
                plunker = ->
                  $timeout ->
                    scope.focuschange = !scope.focuschange
                    plunker() 
                  ,1000
                plunker()
              controller: ($scope) ->
                $scope.status = 0
                $scope.getItem = ->
                  $scope.myItem or $scope.$parent.item
              templateUrl: "#{ang_file_name}.html"
            ]
          FILE
        create_file "app/assets/javascripts/templates/#{ang_file_name}.html.haml", <<-FILE.strip_heredoc
          .#{ang_file_name}
            %span(ng-transclude)
          FILE
      end
    end
  end
end
