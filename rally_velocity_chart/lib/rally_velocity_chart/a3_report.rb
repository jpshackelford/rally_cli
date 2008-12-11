module RallyVelocityChart
  
  class A3Report
    
    def initialize( filename )
      @page_options = {:paper =>  'A3', :orientation => :landscape}
      @filename = filename
      @pdf = nil
    end
    
    def <<( page )
      if @pdf
        page_break! 
      else
        @pdf = new_pdf()
      end
      page.render( @pdf )
    end
    
    def save
      FileUtils.mkdir_p(File.dirname( @filename ))
       ( @pdf || ::PDF::Writer.new ).save_as( @filename )  
    end
    
    private
    
    def new_pdf
      pdf = ::PDF::Writer.new( @page_options )
      pdf.margins_in( top = 0.25, left = 0.25, bottom = 0.25, right = 0.25 )
      return pdf
    end
    
    def page_break!
      @pdf.start_new_page
    end    
  end
  
end
