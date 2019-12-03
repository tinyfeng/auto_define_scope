module AutoDefineScope
  module Engine
    isolate_namespace AutoDefineScope

    ActiveSupport.on_load :active_record do
      include AutoDefineScope::ActiveRecordExtension
    end
  end
end
