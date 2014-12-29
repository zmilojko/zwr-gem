#= require angular
#= require angular-rails-templates
#= require_tree ./templates
#= require_tree ./includes
#= require_self
#= require_tree ./directives
#= require_tree ./services
#= require_tree ./controllers

@zt_module = angular.module('zt', [
  'templates',
  ])