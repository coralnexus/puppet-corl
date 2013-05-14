#
# coral_resources.rb
#
# This function adds resource definitions of a specific type to the Puppet catalog
# - Requires
# - -> Puppet resource definition name (define)
# - -> Hiera lookup name (full name)
# - Optional
# - -> default values for new resources
# If no resources are found, it returns without creating anything.
#
module Puppet::Parser::Functions  
  newfunction(:coral_resources, :doc => <<-EOS
This function adds resource definitions of a specific type to the Puppet catalog
- Requires
- -> Puppet resource definition name (define)
- -> Hiera lookup name (full name)
- Optional
- -> default values for new resources
If no resources are found, it returns without creating anything.
    EOS
) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    function_coral_initialize([])
    
    Coral.run do
      raise(Puppet::ParseError, "coral_resources(): Define at least the resource type and optional variable name " +
        "given (#{args.size} for 1)") if args.size < 1
      
      definition_name = args[0]
      type_name       = definition_name.sub(/^\@?\@/, '')
      var_name        = ( args[1] ? args[1] : definition_name )
      default_values  = ( args[2] ? args[2] : {} )    
      tag             = ( args[3] ? args[3] : '' )
      tag_var         = tag.empty? ? '' : tag.gsub(/\_/, '::')
      override_var    = tag_var.empty? ? nil : "#{tag_var}::#{type_name}"
      default_var     = tag_var.empty? ? nil : "#{tag_var}::#{type_name}_defaults"
      options         = ( args[4] ? args[4] : {} )

      contexts = Coral::Util::Data.prefix(self.source.module_name, [ 'resource', 'coral_resources' ])          
      config   = Coral::Config.init(options, contexts, {
        :scope           => self,
        :init_fact       => 'hiera_ready',
        :resource_prefix => tag,
        :title_prefix    => tag
      })
      resources      = Coral::Config.normalize(var_name, override_var, config)
      default_values = Coral::Config.normalize(default_values, default_var, config) 
    
      #dbg(resources, 'resources -> init')
      #dbg(default_values, 'default_values -> init')
      resources = Coral::Resource.normalize(definition_name, resources, config)
      
      unless Coral::Util::Data.empty?(resources)
        resources.each do |name, data|
          unless data.empty?
            #dbg(data, 'data for merge')
            resource = Coral::Util::Data.merge([ default_values, data ], config)
            #dbg(resource, 'resource after merge')
            resource = Coral::Resource.render(resource, config)
            #dbg(resource, 'post rendered resource')
          
            unless tag.empty?
              if ! data.has_key?('tag')
                resource['tag'] = tag
              else
                resource_tags = data['tag']
                case resource_tags
                when Array
                  resource['tag'] << tag  
                when String
                  resource_tags = resource_tags.split(/\s*,\s*/).push(tag)
                  resource['tag'] = resource_tags
                end
              end
            end
            resources[name] = resource
            #dbg(resources, 'resources after assignment')
          end
        end
        #dbg(resources, 'resources -> pre-translate')
        resources = Coral::Resource.translate(definition_name, resources, config)
        
        #dbg(resources, "#{definition_name} -> result")
        function_coral_create_resources([ definition_name, resources ])
      end
    end
  end
end