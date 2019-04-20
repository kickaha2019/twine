require 'Parser.rb'
require 'Colourer.rb'

game = Parser.new( ARGV[0]).parse
if game.errors > 0
  puts "*** #{game.errors} errors found"
  exit 1
else
  puts "... Parsing successful"
end

colourer = Colourer.new( game)
colourer.run( ARGV[1].to_i, ARGV[2].to_i, ARGV[3], ARGV[4])

puts "... Colouring complete"
