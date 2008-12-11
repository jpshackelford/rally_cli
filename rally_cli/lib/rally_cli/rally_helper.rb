module RallyCLI

  class RallyHelper 
    # Valid options include:
    # :username: Rally username 
    # :password: Rally password
    # :cmd_name: Name of the CLI command.
    # :cmd_ver: Version of the CLI command.
    # :rest_api: Options hash to pass to RallyRestAPI
    def initialize( options = {} )
      @options = options
      rest_api_options = default_options
      rest_api_options = rest_api_options.merge( options[:rest_api] ) if 
        options.has_key?(:rest_api)      
      @r = RallyRestAPI.new( rest_api_options ) 
    end 
    
    def api
      @r
    end
    
    def method_missing( method , *args, &block )
      begin
        helper_class = RallyHelper.const_get( method.to_s.camel_case )
      rescue NameError
        raise NoMethodError.new(
          "undefined local variable or method `#{method}'", method)
      end
      o = helper_class.new( @r, *args, &block )
      o.execute
    end
    
    alias original_respond_to? respond_to?
    
    def respond_to?( method )
      return true if original_respond_to?( method )
      
      helper_class_name = method.to_s.camel_case
      if RallyHelper.constants.include?( helper_class_name ) &&
         RallyHelper.const_get( helper_class_name ).ancestors.
          include?( RallyHelper::AbstractQuery )
          return true
      else
          return false
      end
    end      
    
    def default_options
      { 
        :username => @options[:username] || ENV['RALLY_USERNAME'],
        :password => @options[:password] || ENV['RALLY_PASSWORD'], 
        :http_headers => custom_headers
      }
    end
    
    def custom_headers
      h = CustomHttpHeader.new
      h.name = "Rally CLI #{@options[:cmd_name]}"
      h.version = @options[:cmd_ver] || VERSION 
      h.vendor = 'Pearson'
      return h
    end        
  end
  
end