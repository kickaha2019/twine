require 'Parser.rb'

game = Parser.new( ARGV[0], nil, ARGV[1]).parse

if game.errors
  puts "*** #{game.errors} errors found"
else
  puts "... Parsing successful"
end
