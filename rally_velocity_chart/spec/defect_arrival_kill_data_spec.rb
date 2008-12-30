require File.join(File.dirname(__FILE__), %w[spec_helper])
require 'time'

include RallyVelocityChart

describe DefectArrivalKillData do
  
  before(:all) do      
    # Create test data and mocks. Note all values are meaningless.
    @input = StubTable.new('
      creation_date  opened_date   closed_date     
      2000-01-01     2000-01-02    2000-01-03                
      2000-01-02     2000-01-05    2000-01-06 ')
    
    @output = StubTable.new('
      date          arrivals   kills   active 
      2000-01-01           0       0        1    # Pending defect is active          
      2000-01-02           1       0        2    # Opening counts as an arrival
      2000-01-03           0       1        1    # Closing counts as as kill
      2000-01-04           0       0        1    # All dates in range are in the summary,
                                                 # even if not in the input data  
                                                 # Count items after last creation date:
      2000-01-05           1       0        1    # - Arrivals 
      2000-01-06           0       1        0    # - Kills
      2000-01-07           0       0        0 ') # Range ends at today                        
    
    format_input_table( @input )
    format_output_table( @output )    
  end
  
  before(:each) do 
    @defects_data = DefectArrivalKillData.new( @input.rows )
    
    # Pretend today is the last day in the table
    class << @defects_data
      def today
        Date.parse('2000-01-07')
      end
    end    
  end
  
  it "recognizes created defects" do    
    @defects_data.creations[0].should == 1
  end
  
  it "counts a defect as active, even if it is not yet opened" do
    @defects_data.arrivals[0].should == 0
    @defects_data.active_defects[0].should == 1
  end
  
  it "counts an opened defect as an arrival" do
    @defects_data.arrivals[1]
    @defects_data.arrivals[1].should == 1
  end
  
  it "counts a closed defect as a kill" do
    @defects_data.kills[2].should == 1
  end
  
  it "reduces the active count on a kill" do
    # first verify that the fixture data is what we expect
    @defects_data.active_defects[1].should == 2  
    # now check the active defects
    @defects_data.active_defects[2].should == 1
  end

  it "includes all dates in the range are in summary" do
    @defects_data.arrivals[3].should == 0
    @defects_data.kills[3].should == 0
    @defects_data.active_defects[3].should == 1
  end

  it "counts items after the last creation date" do
    @defects_data.arrivals[4].should == 1
    @defects_data.kills[5].should == 1    
  end

  it "includes an entry for today, the last day of the range" do
    @defects_data.active_defects[6].should == 0
  end
  
  it "calculates arrivals" do
    @defects_data.arrivals.should == @output.cols[:arrivals]     
  end
  
  it "calculates kills" do
    @defects_data.kills.should == @output.cols[:kills]
  end
  
  it "calculates total active" do
    @defects_data.active_defects.should == @output.cols[:active]
  end
   
  it "displays date labels" do
    @defects_data.date_labels.should == ['1/1','1/2','1/3','1/4','1/5','1/6','1/7']    
  end
  
end

def format_output_table( output )
  output.index_by_col(0)  
  output.parse_col(0){|s| Time.parse(s)}
  output.parse_col(1){|s| s.to_i}
  output.parse_col(2){|s| s.to_i}
  output.parse_col(3){|s| s.to_i}
end

def format_input_table( input )
  convert_time = lambda{|s| Time.parse(s).iso8601} 
  input.parse_col(0, &convert_time)
  input.parse_col(1, &convert_time)
  input.parse_col(2, &convert_time)
end
