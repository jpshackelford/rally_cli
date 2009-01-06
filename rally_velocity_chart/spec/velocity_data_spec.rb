require File.join(File.dirname(__FILE__), %w[spec_helper])
require 'time'

include RallyVelocityChart

describe VelocityData do
  
  before(:all) do
    
    iteration1 = StubTable.new('
     creation_date  card_state   card_estimate_total
     2000-01-01     In-Progress   1.0               
     2000-01-01     Completed     2.0
     2000-01-01     Accepted      3.0
     2000-01-02     Completed     4.0
     2000-01-02     Accepted      5.0 ')    
    
    iteration2 = StubTable.new('
     creation_date  card_state   card_estimate_total
     2000-01-03     In-Progress   6.0               
     2000-01-03     Completed     7.0
     2000-01-03     Accepted      8.0
     2000-01-04     Completed     9.0
     2000-01-04     Accepted     10.0 ')    
    
    input = {'Iteration' => iteration1.rows, 'Another Iteration' => iteration2.rows}
    @v = VelocityData.new( input )
  end
  
  it "computes the completed series correctly" do
    @v.completed.should == [4.0, 9.0]
  end
  
  it "computes the accepted series correctly" do
    @v.accepted.should == [5.0, 10.0]
  end
  
  it "computes the committed series correctly" do
    @v.committed.should == [6.0, 21.0]
  end
  
  it "orders the iterations by last date" do
    @v.iteration_sequence.should == ['Iteration', 'Another Iteration']  
  end
  
  it "creates an iteration summary for each iteration, retrievable by name" do
    @v['Iteration'].should be_kind_of( Hash )
    keys = @v['Iteration'].keys
    # nonsense required because Symbol doesn't implement #<=>
    sorted_keys = keys.map{|k|k.to_s}.sort.map{|k|k.to_sym}
    sorted_keys.should == [:accepted, :committed, :completed, :first_day, :last_day]
  end
  
  it "defines completed as the completed estimate total on the last day" do
    @v['Iteration'][:completed].should == 4.0
  end
  
  it "defines accepted as the accepted estimate total on the last day" do
    @v['Iteration'][:accepted].should == 5.0
  end  
  
  it "defines committed as the sum of all card estimates on the first day" do
    @v['Iteration'][:committed].should == 6.0
  end
  
  it "knows which is the first day of an iteration" do
    @v['Iteration'][:first_day] == '2000-01-01'
  end
  
  it "knows which is the last day of an iteration" do
    @v['Iteration'][:last_day] == '2000-01-02'
  end
  
end