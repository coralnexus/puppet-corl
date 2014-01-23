#
# render.rb
#
# Returns the string-ified form of a given value or set of values.
#
module Puppet::Parser::Functions
  newfunction(:render, :type => :rvalue, :doc => <<-EOS
This function returns the string-ified form of a given value.
    EOS
) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    function_coral_initialize([])
    
    value = nil
    Coral.run do
      raise(Puppet::ParseError, "render(): Must have a template class name and an optional source value specified; " +
        "given (#{args.size} for 2)") if args.size < 1
    
      provider = args[0]  
      data     = ( args.size > 1 ? args[1] : {} )
      options  = ( args.size > 2 ? args[2] : {} )
    
      config = Coral::Config.init(options, [ 'data', 'render' ], self.source.module_name, {
        :puppet_scope => self,
        :search       => 'core::default'  
      })
      value = Coral.template(config, provider).render(data)
    end
    return value
  end
end
