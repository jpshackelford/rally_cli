require File.join(File.dirname(__FILE__), %w[spec_helper])

describe GChart::BurnDownChart do
  
  include ImageMatcher
  
  before do
    @data = {'2000-01-01' => {:todo => 10, :completed => 2, :accepted => 1},
             '2000-01-02' => {:todo =>  6, :completed => 1, :accepted => 3},
             '2000-01-03' => {:todo =>  1, :completed => 0, :accepted => 5}}
    @plan_est = 6
    
    @c = GChart::BurnDownChart.new( 
      :data => @data,
      :plan_estimate_total => @plan_est )
  end
  
  it "should save an image that matches the good image we have stored" do
    @c.fetch.should match_image('burndown.png')
  end

  #it "labels the chart with the days of the iteration" do
  #  @c.to_url.should include( esc('chxl=0:|1/1||1/2||1/3||'))
  #end

  it "draws burndown lines from todo data" do
    @c.to_url.should include( esc('t:100.0,0.0,60.0,0.0,10.0'))
  end
 
  it "draws stacked bars" do
    @c.to_url.should include( esc("cht=bvs"))
  end
  
  it "should attempt to fit all bars" do
    @c.to_url.should include( esc("chbh=r,0.2,0.2"))  
  end

  it "draws axis labels on burn down and burn up scales" do
    # third element is max todo for burn down, plan estimate for burn up
    @c.to_url.should include( esc("chxr=0,0,10.0|1,0,6")) 
  end
  
  it "uses the correct colors" do
    @c.to_url.should include( esc("chco=026cfd,76c10f,f5d100"))
  end
  
  it "can be constructed with an object as an alternative to a hash" do
    # mock an object
    chart_data = mock('chart_data')
    chart_data.should_receive(:data).and_return( @data )
    chart_data.should_receive(:plan_estimate_total).and_return( @plan_est )
    # exercise the code
    chart = GChart::BurnDownChart.new( chart_data )
    # see that the object was properly interpreted.
    chart.data.should == @data
    chart.plan_estimate_total.should == @plan_est
  end
 
  it "encodes data properly even when all values are zero" do
    lambda{ @c.enc_set([0.0,0.0,0.0], 0.0) }.should_not raise_error  
  end
  
  # alias
  def esc( string )
    URI.escape( string )
  end  
  
end