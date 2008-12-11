module RallyCLI
  
  class RallyHelper
    
    class RecentIterations < AbstractQuery
      
      def initialize(rally_rest_api, project_name, number )
        super( rally_rest_api )
        @project_name = project_name
        @number       = number
      end
      
      def query
        # The assignments are necessary because 
        # inside the block self == QueryBuilder
        today = now 
        project_name = @project_name
        
        RestQuery.new( :iteration, :pagesize => 100, :fetch => true ) do                              
          equal     :'project.name', project_name
          less_than :end_date, today.iso8601
        end
      end
      
      def post_process( result_array )
        result_array.sort_by{|i| i.end_date}.reverse[0..(@number - 1)]
      end
      
      # make time easier to stub in tests
      def now
        Time.now
      end      
      
    end
  end
  
end