module RallyVelocityChart
  
  class VelocityChartParser < CmdParse::Command
    
    def initialize
      super('velocity_chart', false) # initialize has side-effects
      self.short_desc = 'Create a velocity chart (pdf)'
      self.description = 'Given a project name, create a PDF document ' \
          'which includes burn down charts from the last two iterations and ' \
          'email it to the specified address.'        
      self.options = option_parser
      @opts = OpenStruct.new
    end
    
    def option_parser
      opt_parser = CmdParse::OptionParserWrapper.new do |opt|
        
        opt.on("-p", "--projects PROJECT_01, ...", Array,
                 "The project for which to build the report") do |projects|
          @opts.projects = projects
        end               
  
        opt.on("-f", "--file PATH", 
                 "The file name and path where the PDF should be saved") do |file|
          @opts.file = file      
        end     
        
      end # new
      return opt_parser
    end      
  
    def user_email
      rally_helper.user_email
    end
    
    def rally_helper
      # Create a new RallyHelper passing in command name and version.
      # Username and password should come from the environment variables
      # set by the parent command.
      @helper ||= RallyCLI::RallyHelper.new( 
        :cmd_name => name,
        :cmd_ver  => RallyVelocityChart::VERSION )
      @helper
    end

    # parse command line options but do nothing
    def test_parse( cmd_line )
      args = Shellwords.shellwords( cmd_line )          
      options.permute( args )
    end
    
    # Projects to include in report
    def projects
      @opts.projects
    end
    
    # file to which PDF should be saved.
    def file
      @opts.file
    end
    
    def execute( args )
      puts "Creating report for #{projects.join(', ')}"
      puts "Acquiring data for:"
      report = A3Report.new( file )
      
      # A page for each project
      projects.each do |project|
        print project        
        page = ThreeChartPage.new

        # Use project as page title
        page.title = project
        
        # Add recent iterations charts 
        print ' Burn Down Chart '
        add_burn_down_chart( project, page )     
        
        # Add defect chart        
        print ' Defect Chart '
        add_defect_chart( project, page )
        
        # Add velocity chart
        print ' Velocity Chart '
        add_velocity_chart( project, page )
        
        # Add the page to the report
        report << page
        puts "   (done)"
      end
      
      report.save
      puts "Saved PDF report at #{file}."
    end    
   
   private
   
   def add_burn_down_chart( project, page )
     iters = rally_helper.recent_iterations( project, 1 )
     iteration = iters.first
     data = rally_helper.iteration_cumulative_flow( iteration.oid )
     chart = ::GChart::BurnDownChart.new( BurnDownData.new( data ))
     page.labels << "#{iteration.name} Burn Down"
     page.charts << chart.fetch     
   end
   
   def add_defect_chart( project, page )
      data = rally_helper.project_defects( project )
      chart = ::GChart::DefectChart.new( DefectArrivalKillData.new( data ))
      page.labels << "Defect Summary"      
      page.charts << chart.fetch
   end
   
   def add_velocity_chart( project, page )
     iters = rally_helper.recent_iterations( project, 8 )     
     data = iters.inject({}) do |iterations, iteration|
       summary_data = rally_helper.iteration_cumulative_flow( iteration.oid )
       iterations.store( iteration.name, summary_data )
       iterations
     end
     chart = ::GChart::VelocityChart.new( VelocityData.new( data ))
     page.labels << "Velocity"
     page.charts << chart.fetch
   end
   
  end # parser class
end # module