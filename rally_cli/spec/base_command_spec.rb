require File.join(File.dirname(__FILE__), %w[spec_helper])

include RallyCLI
describe BaseCommand do

  it "keeps track of new commands" do
    initial_size = CLI.command_list.size
    new_class = Class.new( RallyCLI::BaseCommand )
    CLI.command_list.size.should == initial_size + 1
    CLI.command_list.include?( new_class ).should be_true
  end
  
  
end