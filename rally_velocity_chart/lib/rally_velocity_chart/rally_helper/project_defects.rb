module RallyCLI
  
  class RallyHelper
    
    class ProjectDefects < AbstractQuery
      
      def initialize(rally_rest_api, project_name )
        super( rally_rest_api )
        @project_name = project_name
      end
      
      def query
        # The assignments are necessary because 
        # inside the block self == QueryBuilder
         
        project_name = @project_name
        
        RestQuery.new( :defect, :pagesize => 100, :fetch => true ) do                              
          equal :"project.name", project_name
        end
      end
            
    end
  end
  
end