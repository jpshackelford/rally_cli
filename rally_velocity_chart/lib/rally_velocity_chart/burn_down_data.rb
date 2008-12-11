module RallyVelocityChart
  # Adapts rally data for use with BurnDownChart
  class BurnDownData
    
    def initialize( rally_cumulative_flow_data )
      @entries = rally_cumulative_flow_data
    end
    
    def data
      d = {}
      @entries.each do |entry|                 
        # track burn down - sum of all cards
        d[ entry.creation_date] ||= {:todo => 0.0}
        d[ entry.creation_date][ :todo ] += entry.card_to_do_total.to_f
        
        # track burn up - we care only about accepted and completed stories
        state = entry.card_state.downcase.to_sym
        case state
        when :accepted, :completed            
           # record the total for completed or accepted.
           d[ entry.creation_date ][ state ] = entry.card_estimate_total.to_f          
        end
      end
      return d
    end

    # total of all states as of the last day for which we have values
    def plan_estimate_total
      # time format is 2006-01-02T00:00:00.000Z,  
      # we only need 2006-01-02, 10 chars.
      last_day = @entries.map{|e| e.creation_date }.sort.last[0..9]
      @entries.select{|e| e.creation_date[0..9] == last_day }.
        inject(0){|memo,e| memo += e.card_estimate_total.to_f}
    end
    
  end
  
  
end