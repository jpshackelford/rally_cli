require File.expand_path( File.join(File.dirname(__FILE__), %w[.. lib rally_velocity_chart]))

include RallyVelocityChart

png_file = File.join(File.dirname(__FILE__), 'burndown.png') 

a3 = A3Report.new(File.join(File.dirname(__FILE__),'a3.pdf'))
page = ThreeChartPage.new
page.title = "Some Title"
3.times do |n|
  page.labels << "Label #{n}"
  page.charts << open( png_file, 'rb'){|f| f.read }
end
a3.add_page( page )
a3.save
