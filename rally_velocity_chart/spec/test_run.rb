module RallyVelocityChart
  module TestRun
    
    # Execute cmd and return stdout, stderr, and any exceptions
    def test_run( *args )
      begin
        stdout_orig = $stdout; stdout = StringIO.new; $stdout = stdout  
        stderr_orig = $stderr; stderr = StringIO.new; $stderr = stderr
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

  end
end