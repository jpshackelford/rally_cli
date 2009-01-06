module GChart
  
  class VelocityChart < Bar
    
    def initialize(options={}, &block)
      
      # sets up the data
      if !options.kind_of?(Hash)
        my_options = {:data=>[options.accepted,options.completed,options.committed]}
        super my_options
      else
        super(options,&block)
      end
      
      # set the left axis
      self.axis(:left){|a| a.range = 0..highest_value}      
      
      # set chart type
      self.orientation = :vertical
      self.grouped = false
      
      # colors      completed=gold, accepted=green
      self.colors = ['76c10f','f5d100']
      
      # resize bars with the width of the chart
      self.extras={'chbh'=>'a'}
      
      # use the last dataset as a line
      # c.f. http://code.google.com/apis/chart/styles.html#line_styles
      # chm=D,<color>,<data set index>,<data point>,<size>,<priority>      
      self.extras.merge!('chm'=>"D,f3a422,2,0,3,0")
      
      # do not render the last series as a bar
      @render_series = 2
    end 

    # Re-implement to allow for multiple data series 
    # c.f. http://code.google.com/apis/chart/formats.html#multiple_data_series
    def render_data(params) #:nodoc:
      @render_series = data.size if @render_series.nil?
      raw = data && data.first.is_a?(Array) ? data : [data]
      max = self.max || raw.collect { |s| s.max }.max

      sets = raw.collect do |set|
        set.collect { |n| GChart.encode(:extended, n, max) }.join
      end
      params["chd"] = "e#{@render_series}:#{sets.join(",")}"
    end
    
    private
    
    # Returns the highest value of the three data sets
    # for use in the range.
    def highest_value
      if data.kind_of?( Array ) && ! data.empty?
        max = data.flatten.compact.max
      else
        max = 0
      end
      return max
    end
    
    
  end
end
