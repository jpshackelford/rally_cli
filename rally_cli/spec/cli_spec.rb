require File.join(File.dirname(__FILE__), %w[spec_helper])

include RallyCLI

describe CLI do
  
  VERSION_PATTERN = Regexp.new( RallyCLI::VERSION.gsub('.', '\.'))
  
  before do
    @cmd = CLI.new
    @cmd.extend( TestRun )
  end
  
  it "displays a help message" do
    @cmd.test_run('help').stdout.should match(/Usage/)
    @cmd.raise_if_error!
  end
 
  it "lists the version" do
    @cmd.test_run('version').stdout.should match( VERSION_PATTERN )
    @cmd.raise_if_error!
  end
  
  it "supports a help switch as well as a help command" do
    @cmd.test_run('--help').stdout.should match(/Usage/)
    @cmd.raise_if_error!
  end
 
  it "supports a version switch as well as a version command" do
    @cmd.test_run('--version').stdout.should match( VERSION_PATTERN )
    @cmd.raise_if_error!
  end
  
  it "has a registry of commands" do
    new_cmd = Class.new( BaseCommand )
    CLI.add_command( new_cmd )
    CLI.command_list.include?( new_cmd ).should be_true
  end
  
  it "lists new commands in the help" do
    
    class NewCmd 
      class NewCmdParser < CmdParse::Command
        def initialize
          super('new_cmd', true)
        end
      end
      def self.parser
        NewCmdParser 
      end
    end
    
    CLI.add_command( NewCmd )
    
    @cmd.test_run('help').stdout.should match(/new_cmd/)
    @cmd.raise_if_error!
  end

  it "sets the RALLY_USER environment variable with the --user switch" do
    ENV['RALLY_USERNAME'] = nil
    @cmd.test_run('--user', 'username')
    @cmd.raise_if_error!
    ENV['RALLY_USERNAME'].should == 'username'
  end  
  
  it "sets the RALLY_PASSWORD environment variable with the --password switch" do
    ENV['RALLY_PASSWORD'] = nil
    @cmd.test_run('--password'){'password'}.stdout.should match(/Password\: \*{8}/)
    @cmd.raise_if_error!
    ENV['RALLY_PASSWORD'].should == 'password'
  end
  
end