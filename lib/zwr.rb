module Zwr
  require 'zwr/railtie' if defined?(Rails)
  
  require 'zwr/version' if defined?(Rails)
  module ZwrAssets  
    module Rails
      class Engine < ::Rails::Engine
      end
    end
  end  
end