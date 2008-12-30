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
        iters = rally_helper.recent_iterations( project, 2 ).reverse
        iters.each do |iter|
          print " #{iter.name} " 
          data = rally_helper.iteration_cumulative_flow( iter.oid )
          page.labels << iter.name
          page.charts << burn_down_image( data )        
        end
        
        # Add defect chart
        print " defect data "
        data = rally_helper.project_defects( project )
        page.labels << "Defect Summary"
        page.charts << defect_image( data )
        
        # Add the page to the report
        report << page
        puts "   (done)"
      end
      
      report.save
      puts "Saved PDF report at #{file}."
    end    
   
   private
   
   def burn_down_image( data )
     ::GChart::BurnDownChart.new( BurnDownData.new( data )).fetch
   end
   
   def defect_image( data )
     ::GChart::DefectChart.new( DefectArrivalKillData.new( data )).fetch
   end
   
  end # parser class
end # module