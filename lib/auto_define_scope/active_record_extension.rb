module AutoDefineScope
  module ActiveRecordExtension
    OPERATE_SQL = { search: " ilike ?", with: " = ?" }
    attr_accessor :auto_define_scopes

    # For example, CustomerAgentHistory include this
    # columns is a array like ["status", "p_way", {customer_agent: ["code", "name", agent: :province_id]}]
    def search_columns *columns
      generate_cope columns, :search
    end

    def with_columns *columns
      generate_cope columns, :with
    end

    def scopes options = { search: [], with: [] }
      search_columns options[:search]
      with_columns options[:with]
      filterrific available_filters: @auto_define_scopes if @auto_define_scopes.present?
    end

    def add_scope scope_name, lmd
      scope scope_name, lmd
      @auto_define_scopes ||= []
      @auto_define_scopes << scope_name
    end

    protected
    def generate_cope columns, type, klass = self, joins_params_array = []
      columns.each do |c|
        if c.is_a?(Hash)
          c.keys.each do |k|
            association = klass.reflect_on_all_associations.detect{ |a| a.name == k.to_sym }
            raise "scopes defined error, not found association('#{k}') for model #{klass.name}" if association.nil?
            _klass = association.class_name.constantize
            value = c[k].is_a?(Array) ? c[k] : [c[k]] 
            generate_cope value, type, _klass, joins_params_array + [k]
          end
          next
        end
        if c.is_a? Array
          c.each do |v|
            value = v.is_a?(Array) ? v : [v] 
            generate_cope value, type, klass, joins_params_array
          end
          next
        end
        joins_params = joins_params_array.reverse.inject() { |a, n| { n => a } }
        table_name = klass.table_name
        @auto_define_scopes ||= []
        scope_name = "#{type}_#{joins_params_array.last&.to_s&.+ '_'}#{c}"
        @auto_define_scopes << scope_name
        scope scope_name, ->(v) do
          value = type == :with ? v : "%#{v}%"
          joins(joins_params).where("#{table_name}.#{c} #{OPERATE_SQL[type]}", value) 
        end
      end
      nil
    end
  end
end
