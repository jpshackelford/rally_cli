require File.join(File.dirname(__FILE__), %w[spec_helper])

include RallyVelocityChart

describe RallyVelocityChart do
  
  before do
    @cmd = RallyCLI::CLI.new
    @cmd.extend( TestRun ) 
  end
  
  it "appears in the list of available RallyCLI commands" do    
    RallyCLI::CLI.command_list.include?( VelocityChartCommand ).should be_true    
  end

  it "is listed as a command in rally help" do
    @cmd.test_run('help').stdout.should match( Regexp.new( cmd_name ))
  end
    
  it "displays a help message for the command" do
    @cmd.test_run('help', cmd_name ).stdout.should match(/Usage/)
  end
  
#  describe "welcome message" do
#    
#    it "includes the project name when specified" do
#      output = @cmd.test_run( cmd_name , '--project', 'MyProject' ).stdout
#      output.should match(/MyProject/) 
#    end
#    
#    it "defaults to all active projects" do
#      output = @cmd.test_run( cmd_name ).stdout
#      output.should match(/all active projects/) 
#    end
#
#  end
    
  def cmd_name
    VelocityChartParser.new.name
  end

end

# EOF
