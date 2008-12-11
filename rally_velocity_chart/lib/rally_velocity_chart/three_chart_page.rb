module RallyVelocityChart
  
  class ThreeChartPage
    
    attr_accessor :title    
    attr_reader :charts, :labels
    
    def initialize
      @title = nil
      @charts = []
      @labels = []
    end
    
    def render( pdf )
      render_title( pdf, @title )
      @charts[0..2].each_with_index do |chart, index|
        render_chart( pdf, index, chart )
        render_chart_label( pdf , index, @labels[index])
      end
    end
  
    private

    def render_title( pdf, title )
      pdf.open_object do |heading|
        pdf.save_state
        s = 22
        w = pdf.text_width(title, s) / 2.0
        x = pdf.margin_x_middle
        y = pdf.y - 72 
        pdf.add_text(x - w, y, title, s)
        pdf.restore_state
        pdf.close_object
        pdf.add_object(heading, :this_page)
      end 
    end
    
    def render_chart( pdf, position, chart)
      x = 100 + position * 300
      y = pdf.absolute_top_margin - 350
      pdf.add_image( chart, x, y )
    end
  
    def render_chart_label( pdf, position, text )
      x     =  50 + position * 300
      y     =  pdf.absolute_top_margin - 150
      width = 300
      size  = 16
      justification = :center
      pdf.add_text_wrap( x, y , width, text, size, justification)
    end
    
  end

end