require 'Parser.rb'
require 'Viewer.rb'

game = Parser.new( ARGV[0]).parse
if game.errors > 0
  puts "*** #{game.errors} errors found"
  exit 1
end

viewer = Viewer.new( game)
viewer.run( ARGV[1..-1])
