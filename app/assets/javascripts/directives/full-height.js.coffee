@zt_module.directive 'zwrFullHeight', ['$window', ($window) ->
  ret =
    restrict: 'AC'
    setHeight: (elem, h) ->
      elem.attr 'style', "min-height: #{h}px;"
    link: ( scope, elem, attrs ) ->
      angular.element($window).bind "resize", (e) ->
        ret.setHeight(elem, e.srcElement.innerHeight)
      ret.setHeight(elem, $window.innerHeight)
]
