require 'Parser.rb'
require 'Tracer.rb'

game = Parser.new( ARGV[0]).parse
if game.errors > 0
  puts "*** #{game.errors} errors found"
  exit 1
else
  puts "... Parsing successful"
end

tracer = Tracer.new( game, ARGV[3].to_i)
tracer.trace( ARGV[1], ARGV[2])

puts "... Tracing complete"
puts "... #{tracer.solution_count} solutions found"
