require 'zwr'
require 'rails'
module Zwr
  class Railtie < Rails::Railtie
    railtie_name :zwr

    #rake_tasks do
    #  Dir[File.join(File.dirname(__FILE__),'../tasks/*.rake')].each { |f| load f }
    #end

    # Following will allow us to use something like the following 
    # also in the javascript HAML templates:
    #
    # %span=t :'zeljko'
    #
    Sprockets::Context.send :include, ActionView::Helpers::TranslationHelper
  end
end