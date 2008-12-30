require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'time'

include RallyCLI

describe RallyHelper::RecentIterations do
  
  before do
    @q = RallyHelper::RecentIterations.new( nil, 'project_name', 3)
    @q.stub!(:now).and_return( Time.utc(1999,1,1))
  end
  
  it "should issue the appropriate query to Rally's REST API" do
    @q.query.type.should == :iteration
    params = @q.raw_params
    params.should include("query=((Project.Name = project_name) and " +
                          "(EndDate < 1999-01-01T00:00:00Z))")
    params.should include("fetch=true")
    params.should include("pagesize=100")
  end
  
  it "should return only the n lastest, sorted"  do
    raw_results = iterations_ending('1994-01', '1991-01', '1993-01', '1992-01')
    expected_results = iterations_ending( '1994-01', '1993-01', '1992-01')
    @q.post_process( raw_results ).should == expected_results
  end
  
  it "should return a shorter list if fewer than the requested number of " \
     "iterations match the criteria" do
    raw_results = iterations_ending( '1994-01', '1991-01' )
    @q.post_process( raw_results ).size == raw_results.size
  end
  
  it "should be accessbile from the RallyHelper" do
    helper = RallyCLI::RallyHelper.new
    helper.should respond_to( :recent_iterations )
  end
  
  def iterations_ending(*args)
    args.map do |date|
      OpenStruct.new( :end_date => Time.parse( date ))      
    end
  end
  
end