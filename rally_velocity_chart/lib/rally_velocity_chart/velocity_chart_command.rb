module RallyVelocityChart
  
  class VelocityChartCommand < RallyCLI::BaseCommand
  
    def self.parser
      VelocityChartParser 
    end
    
  end
  
end