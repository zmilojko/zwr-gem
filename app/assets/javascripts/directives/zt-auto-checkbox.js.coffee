@zt_module.directive 'ztAutoCheckbox', ->
  directive_object =
    restrict: 'E'       # also possible attribute A and class C
    transclude: true    # set to false if ignoring content
    scope:
      #func: '&reName' # isolate scope of a function, passed as a value 
                       # of the attribute with the name of the directive
      ztItem: '=?'      # isolate scope of a model (both ways), passed with an 
                       # attribute disabled="XXX", where XXX is a variable of 
                       # the scope
      ztField: '@'     # isolate scope of a variable (in only), passed with 
                       # an attribute disabled="123"
    controller: ['$timeout', '$scope', ($timeout, $scope) ->
      $scope.updateSuccess = false
      $scope.updateFail = false
      $scope.updateInProgress = false
      $scope.randomCounter = 0
      $scope.randomCounter2 = 0
      $scope.getItem = ->
        $scope.ztItem or $scope.$parent.item
      $scope.doPerformUpdate = ->
        $scope.updateInProgress = true
        $scope.updateSuccess = false
        $scope.updateFail = false
        $scope.randomCounter2++
        randomCounter2 = $scope.randomCounter2
        $scope.getItem().save()
        .then ->
          if randomCounter2 == $scope.randomCounter2
            $scope.updateInProgress = false
            $scope.updateSuccess = true
            $scope.updateFail = false
            $scope.randomCounter++
            randomCounter = $scope.randomCounter
            $timeout ->
              if randomCounter == $scope.randomCounter
                $scope.updateSuccess = false
            ,2000
        .catch ->
          $scope.getItem().revert()
          $scope.updateInProgress = false
          $scope.updateFail = true
          $scope.updateSuccess = false
    ]
    templateUrl: "zt-auto-checkbox.html" 
