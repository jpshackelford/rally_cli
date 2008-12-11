module RallyCLI
  module TestRun
    
    # Execute cmd and return stdout, stderr, and any exceptions
    def test_run( *args )
      begin
        stdout_orig = $stdout; stdout = StringIO.new; $stdout = stdout  
        stderr_orig = $stderr; stderr = StringIO.new; $stderr = stderr
        
        # handle stdin if specified by the block
        use_as_input( yield ) if block_given?
        
        self.parse( args.flatten ) if self.respond_to?( :parse )
        
        o = OpenStuct.new( :stdout    => stdout.string, 
                           :stderr    => stderr.string,
                           :exception => nil )            
      rescue Exception => e
        @test_run_error = e
        o =  OpenStruct.new( :stdout    => stdout.string, 
                             :stderr    => stderr.string,
                             :exception => e )
      ensure
        $stdout = stdout_orig; $stderr = stderr_orig        
      end    
      return o
    end
    
    def raise_if_error!
      raise @test_run_error if @test_run_error != nil && 
      ! @test_run_error.kind_of?( SystemExit )
    end

    def use_as_input( input_string )
      if ::HighLine::CHARACTER_MODE == "Win32API"
        HighLine.module_eval do
          # Override Windows' character reading so it's not tied to STDIN.
          def get_character( input = STDIN )
            input.getc
          end        
        end
      end              
      stdin = StringIO.new
      stdin << input_string
      stdin.rewind
      $terminal = HighLine.new( stdin )
    end

  end
end