require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe String do
  
  it "can be converted to ruby method name conventions" do
    'TestMe'.underscore.should == 'test_me'
    'Test Me'.underscore.should == 'test_me'
  end
  
  it "can be converted to ruby class name conventions" do 
    'test_me'.camel_case.should == 'TestMe' 
    'test me'.camel_case.should == 'TestMe'
  end
  
  it "cann be converted to xml elemetn name conventions" do
    'test_me'.dasherize.should == 'test-me' 
  end
  
end


