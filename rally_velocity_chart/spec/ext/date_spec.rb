require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include RallyVelocityChart

describe Date do

  it "calculates the last day of the current month" do
    input  = ['2000-02-15', '2000-08-10', '2000-09-05']
    output = [ 29, 31, 30]
    3.times do |i|
      date  = Date.parse( input[i] )
      date.month_end.day.should == output[i]   
    end
  end

  it "advances to a given weekday" do
    
    table = StubTable.new('
    
    :start_date  :weekday  :expectation
    
    2000-12-26       2     2000-12-26
    2000-12-26       5     2000-12-29
    2000-12-26       1     2001-01-01
    2000-12-28       4     2000-12-28
    2000-12-28       6     2000-12-30
    2000-12-28       0     2000-12-31 ')
    
    table.parse_col(0){|s| Date.parse(s)}
    table.parse_col(1){|s| s.to_i}
    table.parse_col(2){|s| Date.parse(s)}
    
    table.rows.each do |a|
      a.start_date.advance_to_weekday( a.weekday ).should == a.expectation
    end
    
  end
  
end