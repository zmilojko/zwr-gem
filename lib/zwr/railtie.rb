require 'zwr'
require 'rails'
module Zwr
  class Railtie < Rails::Railtie
    railtie_name :zwr

    rake_tasks do
      load "tasks/loc.rake"
    end

    # Following will allow us to use something like the following 
    # also in the javascript HAML templates:
    #
    # %span=t :'zeljko'
    #
    Sprockets::Context.send :include, ActionView::Helpers::TranslationHelper
  end
end