require File.join(File.dirname(__FILE__), %w[spec_helper])

include RallyCLI

describe AutoLoader do
  
 it "requires any gems which are dependant on the specified gem" do
   
   auto_loader = AutoLoader.new( 'a_gem' )
   
   auto_loader.stub!( :gems_to_load )   
   auto_loader.stub!( :load_gem )
   
   auto_loader.should_receive(:gems_to_load).and_return(['gem-a','gem-b'])
   auto_loader.should_receive(:load_gem).with('gem-a').once
   auto_loader.should_receive(:load_gem).with('gem-b').once
   
   auto_loader.require_all!
   
 end

 it "looks for dependant gems" do
   auto_loader = AutoLoader.new( 'activesupport' )
   if auto_loader.send(:find_gem, 'activerecord').empty?
     pending "requires ActiveRecord"
   else
    gems_to_load = auto_loader.send(:gems_to_load) 
    gems_to_load.include?('activerecord').should be_true
    gems_to_load.sort.uniq.should == gems_to_load
   end
 end

end