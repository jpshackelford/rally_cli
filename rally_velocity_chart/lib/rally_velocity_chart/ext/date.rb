class Date
  
  def month_end
    # If we advance to 1st day of next month and work backwards
    # we should arrive at the last day of the current month
    return Date.new( year, month + 1, 1) - 1
  end
  
  def advance_to_weekday( day )
    if day > wday
      return self + (day - wday)
    elsif day < wday
      # days til sat + days til selected day  + zero index offset
      return self + (6 - wday) + day + 1
    else  # weekday == day
      return self
    end
  end
  
  def inspect
    to_s
  end
  
end