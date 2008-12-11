module RallyCLI
  
  class RallyHelper
    
    class AbstractQuery
      
      def initialize( rally_rest_api )
        @r = rally_rest_api
      end
      
      def query
        raise NotImplementedError, "subclasses must provide implementation"
      end
      
      # subclasses may override 
      def post_process( result_array )
        result_array
      end
      
      def rally_response
        @r.query( query )      
      end
      
      def all_pages( query_result )
        result_array = []
        this_page = query_result
        begin
          last_page = this_page 
          result_array += this_page.elements[:results]
          this_page = this_page.next_page if this_page.more_pages?
        end while ! last_page.equal? this_page
        result_array
      end
      
      def execute
        post_process( all_pages( rally_response ))
      end
      
      # primarily used in testing
      def raw_params
        URI.unescape( self.query.to_q ).split('&')
      end
      
    end
  end
end