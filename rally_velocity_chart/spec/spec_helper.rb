require File.expand_path( File.join(File.dirname(__FILE__), %w[.. lib rally_velocity_chart]))

require 'handy_matchers'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'test_run'

# set up fixture support
include FixtureSupport
fixture_path_is RallyVelocityChart.path('fixtures')

# As of RallyRestAPI 0.8 attempts to connect in the constructor
# which breaks a bunch of tests
class ::RallyRestAPI
  def initialize( options )    
  end
end


# alias
def esc( string )
  URI.escape( string )
end 