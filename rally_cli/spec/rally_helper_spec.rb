require File.join(File.dirname(__FILE__), %w[spec_helper])

include RallyCLI

# As of RallyRestAPI 0.8 attempts to connect in the constructor
# which breaks a bunch of tests
class ::RallyRestAPI
  def initialize( options ) 
    parse_options( options )
  end
end

describe RallyHelper do
  
  before do
    @helper = RallyHelper.new
  end
  
  it "grants direct access to RallyRestAPI" do
   @helper.api.should be_kind_of( RallyRestAPI )
  end
  
  it "has convenience methods for creating helper objects" do
    mock_query_class = mock('helper_query')
    mock_query_class.should_receive(:execute).once
    mock_query_class.should_receive(:new).
      with( be_kind_of( RallyRestAPI), 1, 2, 3).
      and_return( mock_query_class )

    RallyHelper.const_set(:MockQuery, mock_query_class)    
    @helper.mock_query(1,2,3)
  end
  
  it "supports options for username and password" do
    api = RallyHelper.new(:username => 'name', :password => 'pass').api
    api.username.should == 'name'
    api.password.should == 'pass'
  end
  
  it "uses environment variables if no username and password are specified" do
    ENV['RALLY_USERNAME'] = 'name'
    ENV['RALLY_PASSWORD'] = 'pass'
    api = RallyHelper.new.api
    api.username.should == 'name'
    api.password.should == 'pass'    
  end
  
  it "passes command name into a custom HTTP header" do
    header = RallyHelper.new(:cmd_name => 'mycmd').default_options[:http_headers]
    header.name.should match(/mycmd/)    
  end
  
  it "passes command version into a custom HTTP header" do
    header = RallyHelper.new(:cmd_ver => '0.0.1').default_options[:http_headers]
    header.version.should match(/0\.0\.1/)    
  end
  
  it "passes through RallyRestAPI options" do
    api = RallyHelper.new(:rest_api => {:username => 'name', 
                                        :password => 'pass'}).api
    api.username.should == 'name'
    api.password.should == 'pass'
  end
  
#  it "should support respond_to? for special helper methods" do
#    @helper.should respond_to( :iteration_cumulative_flow )
#    @helper.should respond_to( :recent_iterations )
#  end
  
  it "should raise a NoMethodError if the referenced helper object doesn't exist" do
    lambda{ @helper.no_such_helper(1,2,3)}.should raise_error( NoMethodError )
  end
  
end