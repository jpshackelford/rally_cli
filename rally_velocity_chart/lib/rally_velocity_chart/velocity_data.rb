module RallyVelocityChart
  
  # Adapts rally data for use with VelocityChart
  class VelocityData
  
    # hash keyed by iteration name, with iteration cumulative flow
    # data as the value.
    def initialize( cumulative_flow_by_iteration )
      @raw_data = cumulative_flow_by_iteration
      @velocity_data = nil
      @iteration_sequence = nil
    end    
 
    def[](iteration_name)
      if @velocity_data.nil?        
        @velocity_data = {}
        @raw_data.each_pair do |name, entries|
          iteration = {}
          dates = calc_dates( entries )          
          iteration.store(:first_day, dates.first)
          iteration.store(:last_day,  dates.last)
          iteration.store(:completed, calc_completed( dates.last,  entries ))
          iteration.store(:accepted,  calc_accepted(  dates.last,  entries ))
          iteration.store(:committed, calc_committed( dates.first, entries ))
          @velocity_data.store( name, iteration )
        end
      end
      return @velocity_data[ iteration_name ]
    end
    
    def completed
      iteration_sequence.map do |iter_name|
        self[ iter_name ][:completed]
      end
    end
    
    def accepted
      iteration_sequence.map do |iter_name|
        self[ iter_name ][:accepted]
      end
    end
   
    def committed
      iteration_sequence.map do |iter_name|
        self[ iter_name ][:committed]
      end
    end
  
    def iteration_sequence
      if @iteration_squence.nil?
        @iteration_sequence =
          @raw_data.sort_by do |name, entries|
            entries.map{|e| e.creation_date }.sort.last
          end.map{|iter| iter.first }
      end
      return @iteration_sequence
    end
   
    private
    
    # sequence of dates included in the iteration cumulative flow data, sorted
    # with most recent last.
    def calc_dates( entries )
      entries.map{|e| e.creation_date}.sort
    end
    
    def calc_completed( date, entries )
      entries.find{|e| e.creation_date == date && e.card_state == 'Completed'}.
        card_estimate_total.to_f
    end
    
    def calc_accepted( date, entries )
      entries.find{|e| e.creation_date == date && e.card_state == 'Accepted'}.
        card_estimate_total.to_f
    end

    def calc_committed( date, entries )
      entries.select{|e| e.creation_date == date }.
        inject(0){|memo,e| memo += e.card_estimate_total.to_f}
    end    

  end
end