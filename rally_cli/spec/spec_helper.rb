require File.expand_path( File.join(File.dirname(__FILE__), %w[.. lib rally_cli]))

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'fixture_support'
require 'test_run'

include FixtureSupport
