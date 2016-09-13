APP_ROOT = File.dirname(__FILE__)

$:.unshift( File.join(APP_ROOT, 'lib') )

require 'base'
require 'support/parse_station'
require 'tickets'
# Spider::Base.new
# ParseStation.new.stations
# Ticket.new.stations