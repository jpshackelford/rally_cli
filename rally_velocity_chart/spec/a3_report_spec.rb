require File.join(File.dirname(__FILE__), %w[spec_helper])

include RallyVelocityChart

describe A3Report do

  before do
    @report = A3Report.new( output_file )
  end
  
  after do
    remove_test_output   
  end
  
  it "adds an initial page" do
    page = mock('page')
    page.should_receive(:render).with( an_instance_of( ::PDF::Writer ))
    @report << page 
  end
  
  it "adds subsequent pages" do
    page = mock('page')
    page.should_receive(:render).twice.with( an_instance_of( ::PDF::Writer ))    
    @report.should_receive(:page_break!).once
    @report << page
    @report << page    
  end
  
  it "inserts a page break" do
    pdf = mock('pdf')
    pdf.should_receive(:start_new_page)
    @report.instance_variable_set :@pdf, pdf
    @report.send(:page_break!)
  end
  
  it "saves the file" do
    @report.save
    File.exists?( output_file ).should be_true
  end


  def output_file
    RallyVelocityChart.path('test_output', 'pdf_report.pdf')
  end
  
  def remove_test_output
    FileUtils.rm_rf( File.dirname( output_file ))     
  end
  
end
