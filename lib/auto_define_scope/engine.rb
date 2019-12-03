module AutoDefineScope
  class Engine < ::Rails::Engine
    isolate_namespace AutoDefineScope

    ActiveSupport.on_load :active_record do
      extend AutoDefineScope::ActiveRecordExtension
    end
  end
end
