require File.join(File.dirname(__FILE__), %w[spec_helper])

include RallyVelocityChart

describe ThreeChartPage do
  
  before do
    @page = ThreeChartPage.new
    @pdf = mock('pdf', :null_object => true)
  end
  
  it "has a title" do    
    @page.title = "Some Title"
    @page.render( @pdf )
  end
  
end