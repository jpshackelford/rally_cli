require File.join(File.dirname(__FILE__), %w[spec_helper])

include RallyVelocityChart

describe DailyCounter do

  # Since this class is intended for sub-classing we test with a sub-class to be
  # sure that it is as robust as expected.
  describe "extensions" do
    
    # Sample sub-class
    class OddDayCounter < DailyCounter        
      def round( date )
        if (date.day % 2) == 1
          return date
        else
          return date + 1    
        end
      end
      
      def previous_date( rounded_date )
         rounded_date - 2      
      end      
    end # sample class
  
    before do    
      @dates = mkdates(' 2000-12-24  2000-12-25  2000-12-26 ')
      @counter = OddDayCounter.new( @dates )            
    end

    it "creates a new counter with a first and last date, rounding appropriately" do
      first,last = mkdates('2000-12-24  2000-12-28')
      counter = OddDayCounter.new( first, last )
      counter.dates.should == mkdates('2000-12-25  2000-12-27  2000-12-29')
    end
    
    it "can be initialized without dates" do
      counter = OddDayCounter.new
      counter.dates.should == []
      counter.values.should == []
    end
    
    it "uses roundeds dates with which it is initialized" do
      @counter.dates.should == mkdates('2000-12-25  2000-12-27')
    end
    
    it "initializes counters to zero" do
      @counter.values.should == [0, 0]
    end
    
    it "increments counters (with round dates)" do
      d = mkdates('2000-12-25')    
      @counter.inc( d )
      @counter.values.should == [1,0]
    end
    
    it "increments counters (with dates which need to be rounded)" do
      d = mkdates('2000-12-24')    
      @counter.inc( d )
      @counter.values.should == [1,0]
    end

    it "counter accessor rounds dates in the same way as the incrementor" do
      d = mkdates('2000-12-26')    
      @counter.inc( d )
      @counter[ d ].should == 1      
    end
    
    it "knows max" do
      d = mkdates( '2000-12-27')
      @counter.max.should  == d
      @counter.last.should == d
    end

    it "knows min" do
      d = mkdates( '2000-12-25')
      @counter.min.should   == d
      @counter.first.should == d 
    end
    
    it "concatenates dates" do
      @counter << mkdates('2000-12-29')
      @counter.dates.should == mkdates('2000-12-25  2000-12-27  2000-12-29')
    end
    
    it "sorts dates when concatenated" do
      @counter << mkdates('2000-12-23')
      @counter.dates.should == mkdates('2000-12-23  2000-12-25  2000-12-27')
    end
    
    it "concatenates dates which require rounding" do
      @counter << mkdates('2000-12-28')
      @counter.dates.should == mkdates('2000-12-25  2000-12-27  2000-12-29')    
    end
    
    it "doesn't overwrite values when concatenating existing dates" do
      # setup and verify test
      @counter.inc( mkdates('2000-12-25'))
      @counter.values.should == [1,0]
      # exercise code and test
      @counter << mkdates('2000-12-24') # would be rounded up and overwrite 
      @counter.values.should == [1,0]
      # try again with exact date
      @counter << mkdates('2000-12-25')  
      @counter.values.should == [1,0]      
    end
    
    it "zeros new date counter for concats with :zero behavior" do
      @counter.concat_behavior = :zero
      @counter << mkdates('2000-12-29' )
      @counter.values.should == [0,0,0]
    end
        
    it "uses a previous value for concats with :previous behavior" do
      # setup and verify test
      @counter.inc( mkdates('2000-12-27'))
      @counter.values.should == [0,1]
      # exercise code and test
      @counter.concat_behavior = :previous
      @counter << mkdates('2000-12-29' )
      @counter.values.should == [0,1,1]
    end
    
    it "zeros new date counter with :previous if the new date is the first" do
      # setup and verify test
      @counter.inc( mkdates('2000-12-25'))
      @counter.values.should == [1,0]
      # exercise code and test
      @counter.concat_behavior = :previous
      @counter << mkdates('2000-12-23' )
      @counter.values.should == [0,1,0]
    end
    
    it "concatenates an Array of dates" do
      @counter << mkdates('2000-12-21  2000-12-22')
      @counter.dates.should == 
        mkdates('2000-12-21  2000-12-23  2000-12-25  2000-12-27') 
    end
    
    it "implements empty?" do
      counter = OddDayCounter.new
      counter.should be_empty
      
      counter << mkdates('2000-12-25')
      counter.should_not be_empty
    end
    
  end
  
  describe "default behavior" do
    
    before do
      @dates = mkdates(' 2000-12-24  2000-12-25  2000-12-26 ')
      @counter = DailyCounter.new( @dates )            
    end  

    it "doesn't round dates" do
      @counter.dates.should == @dates
    end
    
    it "uses date - 1 for previous date" do
      d = mkdates('2000-12-25')
      @counter.previous_date( d ).should == d - 1      
    end

    it "uses date - 1 for previous value" do
      # setup the test and be sure test data is what we expect
      @counter.inc( @dates[1] )
      @counter.values.should == [0,1,0]      
      # test:
      @counter.previous_value( @dates[2] ).should == 1
    end
    
    it "default concat behavior is :zero" do
      @counter.concat_behavior.should == :zero  
    end
        
  end
  
  def mkdates( *array )
    if array.flatten.size > 1
      dates = array.flatten.map{|s| Date.parse( s )}.sort 
    else
      dates = array.first.split.map{|s| Date.parse( s )}.sort
    end
    if dates.size == 1 
      return dates.first
    else
      return dates
    end
  end
  
end