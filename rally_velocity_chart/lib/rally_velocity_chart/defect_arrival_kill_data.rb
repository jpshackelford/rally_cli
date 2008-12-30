module RallyVelocityChart
  
  class DefectArrivalKillData
    
    def initialize( defect_records )
      @defect_records = defect_records.sort_by{|d| d.creation_date }
      @last_n           = 30
      @unit             = :days
      reset_summary!
    end
    
    def creations
      tally_defect_records unless tally_complete?
      truncated_summary_of( :creations )      
    end
    
    def arrivals
      tally_defect_records unless tally_complete?
      truncated_summary_of( :arrivals )
    end
    
    def kills
      tally_defect_records unless tally_complete?
      return truncated_summary_of( :kills )
    end
    
    def active_defects      
      tally_defect_records unless tally_complete?
      tally_active_defects if @summary[:active_defects].empty?
      return truncated_summary_of( :active_defects )
    end
    
    def date_labels
      tally_defect_records unless tally_complete?
      generate_date_labels if @summary[:date_labels].empty?
      return truncated_summary_of( :date_labels )
    end
    
    def by_day
      unless @unit == :days      
        @unit = :days
        reset_summary!
      end
    end
    
    def last( n )
      unless @last_n == n
        @last_n = n
        reset_summary!
      end
    end
    
    private
    
    def reset_summary!
      counter_class = counter_for( @unit )
      @summary = 
      { :creations      => counter_class.new,
        :arrivals       => counter_class.new, 
        :kills          => counter_class.new, 
        :active_defects => [] , 
        :date_labels    => [] }
    end
    
    # TODO: Perhaps this should be pulled up into a factory or into DailyCounter.
    def counter_for( unit )
      case unit
      when :days
        return DailyCounter
      end
    end
    
    def tally_defect_records
      # count up creation, arrival, and kill for each record
      @defect_records.each{|d| tally_defect( d )}
      
      # fill in missing days and normalize range
      normalize!( :creations, :arrivals, :kills )
    end
    
    def tally_complete?
      ! @summary[ :arrivals ].empty?
    end
    
    def truncated_summary_of( series )
      
      # This series a Counter or an Array?
      if @summary[ series ].respond_to?( :values )
        dataset =  @summary[ series ].values
      elsif @summary[ series ].is_a?( Array )
        dataset = @summary[ series ]
      end

      start = 0 - [ @last_n, dataset.size ].min

      return dataset[start..-1]
    end
    
    def tally_defect( record )
      tally_field( :creations, :creation_date, record )
      tally_field( :arrivals,  :opened_date,   record )
      tally_field( :kills,     :closed_date,   record )
    end
    
    def tally_field( series, field_method, record )
      date_string = record.send( field_method ) 
      unless date_string.nil?
        date = Date.parse( date_string )
        @summary[ series ].inc( date )        
      end
    end
    
    def normalize!( *series_list )
      # dates which ought to appear in each series
      expected = canonical_dates()
      # figure out which dates are missing and add them
      series_list.each do |series|      
        actual = @summary[series].dates
        missing_dates = expected - actual
        @summary[series] << missing_dates   
      end
    end
    
    def tally_active_defects
      # initialize and create a shorthand
      total = @summary[:active_defects] = [0]
      
      # walk through all of the dates, assuming that #tally_complete?
      canonical_dates.each_with_index do |date, this_day|                 
        
        # bring forward the previous day's total
        total[ this_day ] = total[ this_day - 1 ] unless this_day == 0

        # account for new creates and kills
        total[ this_day ] += ( @summary[:creations][date] - @summary[:kills][date] )               
      end
      return total
    end

    def generate_date_labels
      labels = []
      canonical_dates.each do |date|
        labels << "#{date.month}/#{date.day}"
      end
      @summary[:date_labels] = labels
    end
    
    # earliest adjusted date in tallied data
    def min_date            
      # min of the min in each series, series dates are already adjusted
      return [:creations,:arrivals,:kills].
             map{|series| @summary[ series ].min}.compact.min
    end
    
    # All of the dates each range should include.
    def canonical_dates      
      counter_for( @unit ).new( min_date , today ).dates
    end
    
    def today      
      Date.today
    end
        
    #    def adjusted_date( date , unit)
    #      case unit
    #      when :day
    #        new_date = date
    #        # could put count weekends as monday logic here
    #      when :week
    #        # count forward to next Friday; Sun == 0, Sat == 6
    #        new_date = date.advance_to_weekday( 5 ) 
    #      when :month
    #        # count forward to last day of the month
    #        new_date = date.month_end
    #      end
    #      return new_date
    #    end
    
    #    # list of all dates from the earliest date
    #    # to the current selected by unit
    #    def date_list
    #      case @unit
    #      when :day
    #        result = (min_date..today).to_a
    #      when :week
    #        result = date_sequence( min_date, today, 7)
    #      when :month
    #        result = month_end_sequence( min_date, today)
    #      end
    #      return result
    #    end
    
    #    def month_end_sequence( first, last )
    #      result = []
    #      next_date = first
    #      while next_date <= last
    #        result << next_date
    #        next_date = (next_date+1).month_end
    #      end
    #      return result
    #    end
    #    
    #    def date_sequence(first, last, inc)
    #      result = []
    #      next_date = first
    #      while next_date <= last
    #        result << next_date
    #        next_date += inc
    #      end
    #      return result
    #    end
    
  end
  
end
