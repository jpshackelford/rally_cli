module RallyCLI
  
  class BaseCommand
    
    def self.inherited( aClass )
      CLI.add_command( aClass )
    end
    
  end
  
end

