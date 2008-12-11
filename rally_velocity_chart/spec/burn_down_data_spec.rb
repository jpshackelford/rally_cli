require File.join(File.dirname(__FILE__), %w[spec_helper])

include RallyVelocityChart

describe BurnDownData do

  before do    
    
    # Create test data and mocks. Note all values are meaningless.
    data = entries(
    # Creation Date  CardState    CardEstimateTotal  ToDoTotal 
    ' 2000-01-01     In-Progress  1.0                7.0               
      2000-01-01     Completed    2.0                8.0
      2000-01-01     Accepted     3.0                9.0
      2000-01-02     In-Progress  4.0               10.0
      2000-01-02     Completed    5.0               11.0
      2000-01-02     Accepted     6.0               12.0        ')
    
   @burndown = BurnDownData.new( data )
  end
  
  it "provides data in format expected by BurnDownChart" do
    @burndown.data.should ==
      { '2000-01-01' => { :completed => 2.0, 
                          :accepted  => 3.0, 
                          :todo      =>  7.0 +  8.0 +  9.0 },
                          
        '2000-01-02' => { :completed => 5.0, 
                          :accepted  => 6.0, 
                          :todo => 10.0 + 11.0 + 12.0}
      }
  end

  it "calculates plan estimate total" do
    @burndown.plan_estimate_total.should == 15 # sum of all states on final day
  end
  
end

# format test data to match results of IterationCumulativeFlow Rally helper.
def entries( rows )
  rows.split("\n").map do |line|
    row = line.split
    OpenStruct.new(
      :creation_date       => row[0],
      :card_state          => row[1],
      :card_estimate_total => row[2],
      :card_to_do_total    => row[3]
    )
  end
end
