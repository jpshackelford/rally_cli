module RallyCLI
  
  class RallyHelper
    
    class IterationCumulativeFlow < AbstractQuery
      
      def initialize(rally_rest_api, iteration_object_id )
        super( rally_rest_api )
        @object_id = iteration_object_id
      end
      
      def query
        # The assignments are necessary because 
        # inside the block self == QueryBuilder
         
        object_id = @object_id
        
        RestQuery.new( :iteration_cumulative_flow_data, :pagesize => 100, :fetch => true ) do                              
          equal :iteration_object_i_d, object_id
        end
      end
            
    end
  end
  
end