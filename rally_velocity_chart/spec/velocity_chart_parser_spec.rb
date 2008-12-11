require File.join(File.dirname(__FILE__), %w[spec_helper])
require 'shellwords'

include RallyVelocityChart


describe VelocityChartParser do
  
  before do
    @parser = VelocityChartParser.new
    @parser.extend( TestRun )
  end
  
  it "is a Rally CLI command called 'velocity_chart'" do
    @parser.name.should == 'velocity_chart'
  end
  
  describe "rally_helper" do
    
    it "instantiated with commmand name and version" do    
      h = @parser.rally_helper
      h.custom_headers.name.should match( Regexp.new( @parser.name ))
      h.custom_headers.version.should == RallyVelocityChart::VERSION
    end
    
    it "is lazy loaded" do
      o = Object.new
      @parser.instance_variable_set :@helper, o 
      @parser.rally_helper.object_id.should == o.object_id
    end
    
    it "is a singleton" do
      @parser.rally_helper.object_id.should == @parser.rally_helper.object_id
    end
    
  end
  
  describe "command-line options" do    
    it "allows me to specify a list of projects" do
      @parser.test_parse('--project x,y,z')
      @parser.projects.should == ['x','y','z']
    end  
  end
  

  
end
