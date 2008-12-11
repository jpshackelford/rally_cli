require File.join(File.dirname(__FILE__), '..', %w[spec_helper])

include RallyCLI

describe RallyHelper::IterationCumulativeFlow do

  before do
    @q = RallyHelper::IterationCumulativeFlow.new( nil, 'ITERATION_OBJECT_ID')
  end

  it "should issue the appropriate query to Rally's REST API" do
    @q.query.type.should == :iteration_cumulative_flow_data
    params = @q.raw_params
    params.should include("query=(IterationObjectID = ITERATION_OBJECT_ID)")
    params.should include("fetch=true")
    params.should include("pagesize=100")
  end

  it "should be accessbile from the RallyHelper" do
    helper = ::RallyCLI::RallyHelper.new
    helper.should respond_to( :iteration_cumulative_flow )
  end

end
