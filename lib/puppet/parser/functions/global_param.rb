#
# global_param.rb
#
# This function performs a lookup for a variable value in various locations
# following this order
# - Hiera backend, if present (no prefix)
# - ::coral::default::varname
# - ::varname
# - {default parameter}
#
# Inspired by example42 -> params_lookup.rb (in the Puppi module)
#
require 'pp'

module Puppet::Parser::Functions
  newfunction(:global_param, :type => :rvalue, :doc => <<-EOS
This function performs a lookup for a variable value in various locations following this order:
- Hiera backend, if present (no prefix)
- ::coral::default::varname
- ::varname
- {default parameter}
If no value is found in the defined sources, it returns an empty string ('')
    EOS
) do |args|

    raise(Puppet::ParseError, "global_param(): Define at least the variable name " +
      "given (#{args.size} for 1)") if args.size < 1

    value         = ''
    var_name      = args[0]
    default_value = ( args[1] ? args[1] : '' )
    context       = ( args[2] ? args[2] : '' )
    base          = ( args[3] ? args[3] : '::coral::default' )
    
    if function_config_initialized([])
      case context
      when 'array'
        value = function_hiera_array([ "#{var_name}", '' ])
      when 'hash'
        value = function_hiera_hash([ "#{var_name}", '' ])
      else
        value = function_hiera([ "#{var_name}", '' ])
      end
    end
    
    puts "global_param -> #{var_name}"
    #pp value
    #pp lookupvar("#{base}::#{var_name}")
    #pp lookupvar("::#{var_name}")
    #pp default_value

    value = lookupvar("#{base}::#{var_name}") if value == :undefined || value == ''
    value = lookupvar("::#{var_name}") if value == :undefined || value == ''    
    value = default_value if value == :undefined || value == ''
    
    pp value    
    return value
  end
end
