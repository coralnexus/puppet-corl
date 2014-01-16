#
# module_hash.rb
#
# See: module_param.rb
#
module Puppet::Parser::Functions
  newfunction(:module_hash, :type => :rvalue, :doc => <<-EOS
This function performs a lookup for a variable value in various locations:
See: module_params()
If no value is found in the defined sources, it returns an empty hash ({})
    EOS
) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    function_coral_initialize([])
    
    value = nil
    Coral.run do
      raise(Puppet::ParseError, "module_hash(): Define at least the variable name " +
        "given (#{args.size} for 1)") if args.size < 1

      var_name      = args[0]
      default_value = ( args.size > 1 ? args[1] : {} )
      options       = ( args.size > 2 ? args[2] : {} )
    
      contexts = function_option_contexts([ 'param', 'module_hash' ])
      config   = Coral::Config.init(options, contexts).set(:context, :hash)
      value    = function_module_param([ var_name, default_value, config.export ])
    end
    return value
  end
end
