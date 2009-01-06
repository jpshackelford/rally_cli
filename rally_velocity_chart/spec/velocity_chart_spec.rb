require File.join(File.dirname(__FILE__), %w[spec_helper])

describe GChart::VelocityChart do
  
  include ImageMatcher
  
  before(:all) do 
    @sample_data = [10,9,8,7,6,5,4,3,2,1]
  end
  
  describe "when initialized with an object" do

    class ChartDataStub
      attr_accessor :completed, :accepted, :committed
    end

    before do 
      @chart_data = ChartDataStub.new
    end
    
    it "renders accepted as series 1" do
      @chart_data.accepted = @sample_data
      chart = GChart::VelocityChart.new(@chart_data)
      chart.data[0].should == @sample_data
    end
    
    it "renders completed as series 2" do
      @chart_data.completed = @sample_data
      chart = GChart::VelocityChart.new(@chart_data)
      chart.data[1].should == @sample_data
    end
    
    it "renders commitment as series 3" do
      @chart_data.committed = @sample_data
      chart = GChart::VelocityChart.new(@chart_data)
      chart.data[2].should == @sample_data
    end  
  end

  it "renders completed when initialized with a hash" do
    chart = GChart::VelocityChart.new(:data => [@sample_data,[],[]])
    chart.data[0].should == @sample_data    
  end
  
  it "renders completed when initialized with a block" do
    chart = GChart::VelocityChart.new do |g|
      g.data = [@sample_data,[],[]]
    end
    chart.data[0].should == @sample_data    
  end
  
#  it "draws left axis range using highest value in the dataset" do
#    # sample data
#    dataset = []
#    
#    # values:  Arrivals, Kills, Active
#    dataset << [[1,2],[3,4],[5,6]] # dataset 1
#    dataset << [[9,8],[7,6],[5,4]] # dataset 2
#    
#    # test with several datasets
#    dataset.each do |test_data|
#      chart = GChart::VelocityChart.new do |g|
#        g.data = test_data
#      end
#      chart.to_url.should include( esc("chxr=0,0,#{test_data.flatten.max}") )
#    end
#  end
   
  describe do
    
    before do
      # data is arbitrary but should match defect.png in fixtures directory.
      @c = GChart::VelocityChart.new( :data => [[1,2],[3,4],[5,6]] ) 
    end
    
    it "draws vertical bars stacked" do    
      type = @c.render_chart_type
      type.should == 'bvs'    
    end
    
    it "colors accepted green" do
      @c.colors[0].should == '76c10f' 
    end
    
    it "colors completed gold" do
      @c.colors[1].should =='f5d100' 
    end
    
    it "displays commitment as a line" do
      # chm=D,<color>,<data set index>,<data point>,<size>,<priority>
      @c.to_url.should match(/chm=D,/)        
    end

    describe "commitment line" do

      before do
        # See http://code.google.com/apis/chart/styles.html#line_styles
        # chm=D,<color>,<data set index>,<data point>,<size>,<priority>
        @c.to_url =~ /chm=D,(\w{6}),(\d{1}),(\d{1}),(\d{1}),(\d{1})/
        @color         = $1
        @dataset_index = $2
        @data_points   = $3
        @size          = $4
        @priority      = $5
        # See http://code.google.com/apis/chart/styles.html#line_styles
        # chls=<data set 1 line thickness>,<length of line segment>,<length of blank segment>
        #@c.to_url =~ /chls=(\d{1}),(\d{1}),(\d{1})/
        
      end
        
      it "is orange" do
        @color.should == 'f3a422' 
      end
    
      it "is rendered from the committed data" do
        @dataset_index.should == '2'
      end
    
      it "uses all points in the dataset" do
        @data_points.should == '0'
      end

      it "is three pixels wide" do
        @size.should == '3'
      end

      it "is drawn after bars or chart lines, but before other lines" do
        @priority.should == '0'
      end

    end
  
    it "does not display commitment as a bar" do
      # See http://code.google.com/apis/chart/formats.html#multiple_data_series
      # Format is chd=<encoding type><chart data series>:<chart data string>
      # where <chart data series> is the number to display on the chart. 
      # Additional series may be used to draw line using chm=D...
      @c.to_url.should match(/chd=e2\:/)
    end

    it "resizes bars according to the chart width" do
      @c.to_url.should match(/chbh=a/)
    end

    it "should save an image that matches the good image we have stored" do
      @c.fetch.should match_image('velocity.png')
    end
    
  end
  
end
