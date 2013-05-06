#
# module_param.rb
#
# This function performs a lookup for a variable value in various locations
# following this order
# - Hiera backend, if present (modulename prefix)
# - ::coral::default::{modulename}::{varname} (configurable!!)
# - ::{modulename}::default::{varname}
# - {default parameter}
#
module Puppet::Parser::Functions
  newfunction(:module_param, :type => :rvalue, :doc => <<-EOS
This function performs a lookup for a variable value in various locations following this order:
- Hiera backend, if present (modulename prefix)
- ::data::default::{modulename}_{varname} (configurable!!)
- ::{modulename}::default::{varname}
- {default parameter}
If no value is found in the defined sources, it returns an empty string ('')
    EOS
) do |args|
    value = nil
    Coral.backtrace do
      raise(Puppet::ParseError, "module_param(): Define at least the variable name " +
        "given (#{args.size} for 1)") if args.size < 1
      
      var_name        = args[0]
      default_value   = ( args.size > 1 ? args[1] : '' )
      options         = ( args.size > 2 ? args[2] : {} )
    
      module_name      = self.source.module_name
      module_var_name  = "#{module_name}::#{var_name}"
      default_var_name = "#{module_name}::default::#{var_name}"
    
      config = Coral::Config.new(options, {
        :scope       => self,
        :init_fact   => 'hiera_ready',
        :search      => 'global::default',
        :search_name => false,
        :force       => true
      })    
      value = Coral::Config.lookup(module_var_name, nil, config)
    
      if value.nil?
        value = lookupvar(default_var_name)
      end
    
      if value.nil?
        value = default_value
        
      elsif ! default_value.empty?
        context = config.get(:context, false)
        if context && (context == :array || context == :hash)
          value = Coral::Data.merge([default_value, value], config)
        end
      end
    
      Coral::Config.set_property(module_var_name, value)
      #dbg(value, "param -> #{module_var_name}")
    end
    return value
  end
end
