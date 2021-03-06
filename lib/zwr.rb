module Zwr
  if defined?(Rails)
    require 'zwr/railtie' 
    require 'zwr/version'
    
    module ZwrAssets  
      module Rails
        class Engine < ::Rails::Engine
        end
      end
    end  
  end
  
  if defined?(Mongoid)
    require 'zwr/zwr_mongoid.rb'
  end
end