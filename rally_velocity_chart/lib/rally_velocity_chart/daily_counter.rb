# Tally data by day. Override #round and #previous_date in sub-classes to create
# classes that aggregate data for other intervals.  
class DailyCounter
   
  # Creates a new daily counter from an Array of dates. Counter values are 
  # initialized to zero. Dates a rounded to select valid dates from the input. 
  # This implementation considers every date valid, but may be sub-classed to 
  # provide an implementation of #round that handles coercing input dates to
  # acceptable dates.
  #
  # Note that if initialized with an Array of two elements, it will be interpreted
  # as a date range. Each day will be rounded and the constructor will walk
  # backwards from the high date to the low using #previous_date to fill-in the
  # missing elements. Thus behavior in sub-classes will be as expected when
  # #round and #previous_date are implemented.
  def initialize( *array )
    @sequence = {}
    if array.flatten.size == 2
      # interpret as a range, walk backwards and populate 
      first, last = array.flatten.map{|d| round(d)}.sort
      date = last
      while date >= first
        @sequence.store( date, 0 )
        date = previous_date( date )
      end
    else # interpret as an array of dates          
      array.flatten.each do |date|
        @sequence.store( round(date), 0 )  
      end
    end
    @dates, @values = nil
    @concat_behavior = :zero
  end

  # Last date in the sequence of old to new date.
  def max
    dates.last  
  end
  
  alias last max 
  
  # First date in the sequence of old to new dates.
  def min
    dates.first
  end
  
  alias first min
  
  # Return the counter value for a given date. The date is rounded internally
  # by #round and so may be called with any date to aggregate for a particular
  # period.
  def []( date )
    @sequence[ round( date )]
  end  
  
  # Increase the counter for the given date by one. The date is rounded internally
  # by #round and so may be called with any date to aggregate for a particular
  # period. If the date does not yet exist, it is added using #<< before 
  # incrementing by one, but this is slower than adding the dates first.
  def inc( date )    
    rounded_date = round( date ) 
    begin
      @sequence[ rounded_date ] += 1
    rescue NoMethodError # can't add one to nil
      self << rounded_date # sweeps cache
      retry
    else 
      @values = nil # sweep cache  
    end    
  end
  
  # Determine what behavior to use for determing values when dates are added 
  # with #<<. Valid options are:
  # :previous: Assume the value of the previous entry or zero if the added date
  #            is now the first entry.
  # :zero:     Assume the value is always for each new date added. 
  attr_accessor :concat_behavior

  # Add another date to the sequence. Values for the new date are computed 
  # using #concat_behavior. If the date parameter is an Array of dates, iterate
  # over the Array concatenating each element. Dates which already exist will 
  # not be added and rounding rules applied to all added dates. 
  # Always returns nil.
  def <<( add_this )            
    # Single Dates
    if add_this.is_a?( Date )          
      rounded_date = round( add_this )
      if @sequence.keys.include?( rounded_date )
        # do nothing, we already have this date
      elsif @concat_behavior == :zero || rounded_date < min   
        # no earlier value to use, assume zero
        @sequence.store( rounded_date, 0)
      elsif @concat_behavior == :previous 
        # use earlier value as this one
        @sequence.store( rounded_date, previous_value( rounded_date ))
      end
    # Arrays of Dates
    elsif add_this.is_a?( Array )
      add_this.each{|d| self << d}    
    else # ERROR
      raise ArgumentError, "Expected an Array of Dates or a Date."
    end  
    @dates, @values = nil # sweep cache
  end
   
  # Return a Array of values in date sequence. This is cached so repeated calls
  # will not incur the expense of computing the Array. The sequence is sorted
  # old to new.
  def values
    @values ||= dates.map{|d| @sequence[d]}  
  end

  # Return a Array of dates in the sequence. This is cached so repeated calls
  # will not incur the expense of computing the Array. The dates are sorted old
  # to new.
  def dates
    @dates ||= @sequence.keys.sort
  end

  # Round the date to a valid date. Useful when a counter is needed to summarize
  # data on a weekly or monthly or some other basis. This implementation simply
  # returns the input. When #round is overridden, #previous_value must also be.
  def round( date )
    return date
  end
  
  # Given a date which has been rounded by #round, select the previous date in 
  # the sequence which should also be returnable by #round. This method may 
  # should also return a date less than #min when #min or a rounded date less
  # than #min is supplied as input. May be overridden in sub-classes, but do
  # implement a complementary #round.
  def previous_date( rounded_date )
    rounded_date - 1
  end
  
  # Returns the previous value using #previous_date  
  def previous_value( rounded_date )
    return @sequence[ previous_date( rounded_date ) ]  
  end
  
  # Indicates whether counter has dates and/or values.
  def empty?
    @sequence.empty? 
  end
  
end