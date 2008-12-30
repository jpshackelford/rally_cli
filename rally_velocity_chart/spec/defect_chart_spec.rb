require File.join(File.dirname(__FILE__), %w[spec_helper])

describe GChart::DefectChart do
  
  include ImageMatcher
  
  before(:all) do 
    @sample_data = [10,9,8,7,6,5,4,3,2,1]
  end
  
  describe "when initialized with an object" do

    class ChartDataStub
      attr_accessor :arrivals, :kills, :active_defects
    end

    before do 
      @chart_data = ChartDataStub.new
    end
  
    it "renders arrivals as series 1" do
      @chart_data.arrivals = @sample_data
      chart = GChart::DefectChart.new(@chart_data)
      chart.data[0].should == @sample_data
    end
    
    it "renders kills as series 2" do
      @chart_data.kills = @sample_data
      chart = GChart::DefectChart.new(@chart_data)
      chart.data[1].should == @sample_data
    end
    
    it "renders active defects as series 3" do
      @chart_data.active_defects = @sample_data
      chart = GChart::DefectChart.new(@chart_data)
      chart.data[2].should == @sample_data
    end  
  end

  it "renders arrivals when initialized with a hash" do
    chart = GChart::DefectChart.new(:data => [@sample_data,[],[]])
    chart.data[0].should == @sample_data    
  end
  
  it "renders arrivals when initialized with a block" do
    chart = GChart::DefectChart.new do |g|
      g.data = [@sample_data,[],[]]
    end
    chart.data[0].should == @sample_data    
  end
  
  it "draws left axis range using highest value in the dataset" do
    # sample data
    dataset = []
    
    # values:  Arrivals, Kills, Active
    dataset << [[1,2],[3,4],[5,6]] # dataset 1
    dataset << [[9,8],[7,6],[5,4]] # dataset 2
    
    # test with several datasets
    dataset.each do |test_data|
      chart = GChart::DefectChart.new do |g|
        g.data = test_data
      end
      chart.to_url.should include( esc("chxr=0,0,#{test_data.flatten.max}") )
    end
  end
   
  describe do
    
    before do
      # data is arbitrary but should match defect.png in fixtures directory.
      @c = GChart::DefectChart.new( :data => [[1,2],[3,4],[5,6]] ) 
    end
    
    it "knows the Google Chart type to use" do    
      type = @c.render_chart_type
      type.should == 'bvg'    
    end
    
    it "colors arrivals red" do
      @c.colors[0].should =='fd0000' 
    end
  
    it "colors kills green" do
      @c.colors[1].should == '76c10f' 
    end
    
    it "displays active defects as a line" do
      # chm=D,<color>,<data set index>,<data point>,<size>,<priority>
      @c.to_url.should match(/chm=D,/)        
    end

    describe "active defects line" do

      before do
        # See http://code.google.com/apis/chart/styles.html#line_styles
        # chm=D,<color>,<data set index>,<data point>,<size>,<priority>
        @c.to_url =~ /chm=D,(\w{6}),(\d{1}),(\d{1}),(\d{1}),(\d{1})/
        @color         = $1
        @dataset_index = $2
        @data_points   = $3
        @size          = $4
        @priority      = $5
      end
        
      it "is blue" do
        @color.should == '026cfd' 
      end
    
      it "is rendered from the active defects data" do
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
  
    it "does not display active defects as a bar" do
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
      @c.fetch.should match_image('defect.png')
    end
    
  end
  
end
