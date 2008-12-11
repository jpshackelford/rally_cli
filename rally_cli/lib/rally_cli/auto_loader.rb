module RallyCLI
  
  # Loads commands from other installed gems.
  class AutoLoader
    
    def initialize( this_gem )
      @parent_gem = this_gem
    end
    
    def require_all!
      gems_to_load.each do |gem_name| 
        load_gem( gem_name )
      end
    end
    
    private
    
    def find_gem( name )
      Gem.source_index.search( name )
    end
    
    def gems_to_load
      load_these = []
      found = find_gem( @parent_gem )
      found.each do |gem|
        gem.dependent_gems.each do |dep|
          load_these << dep.first.name
        end        
      end
      load_these.sort.uniq
    end
    
    def load_gem( gem_name )
      require gem_name
    end  
    
  end
end