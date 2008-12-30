require File.join(File.dirname(__FILE__), %w[.. spec_helper])

include RallyCLI

describe RallyHelper::ProjectDefects do

  before do
    @q = RallyHelper::ProjectDefects.new( nil, 'PROJECT_NAME')
  end

  it "should issue the appropriate query to Rally's REST API" do
    @q.query.type.should == :defect
    params = @q.raw_params
    params.should include("query=(Project.Name = PROJECT_NAME)")
    params.should include("fetch=true")
    params.should include("pagesize=100")
  end

  it "should be accessbile from the RallyHelper" do
    helper = ::RallyCLI::RallyHelper.new
    helper.should respond_to( :project_defects )
  end

end