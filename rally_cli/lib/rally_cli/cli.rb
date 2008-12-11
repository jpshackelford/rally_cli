module RallyCLI
  class CLI 
    
    class << self
      
      def add_command( aClass )
        @command_list ||= []
        @command_list << aClass
      end

      def command_list
        @command_list ||= []
        @command_list.dup
      end

    end
    
    def parse( args )
      # setup command parse
      cmd = CmdParse::CommandParser.new( true, true )
      cmd.program_name = File.basename( $PROGRAM_NAME )
      cmd.program_version = RallyCLI::VERSION.split('.').map{|s| s.to_i}
      cmd.options = available_options 
      
      # add commands
      cmd.add_command( CmdParse::HelpCommand.new, true ) # default command
      cmd.add_command( CmdParse::VersionCommand.new )
     
      # load commands from other gems
      self.class.command_list.each do |cmd_class|
        if cmd_class.respond_to?( :parser ) &&
           cmd_class.parser.ancestors.include?( CmdParse::Command )
          cmd.add_command( cmd_class.parser.new )
        end
      end
      
      # parse and execute commands
      cmd.parse( args )         

    end
    
    private
    
    def available_options
      CmdParse::OptionParserWrapper.new do |opt|

        opt.on('-u', '--user RALLY_USERNAME',  'set Rally username') do |user|
          ENV['RALLY_USERNAME'] = user
        end
        
        opt.on('-p', '--password', 'set Rally password') do
          ENV['RALLY_PASSWORD'] = ask('Password: '){|q| q.echo = '*'}
        end
      
      end
    end
    
  end
end