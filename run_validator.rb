require 'Parser.rb'
require 'Validator.rb'

game = Parser.new( ARGV[0]).parse

if game.errors > 0
  puts "*** #{game.errors} parse errors found"
  exit 1
else
  puts "... Parsing successful"
end

validator = Validator.new( game)
validator.run

if validator.errors > 0
  puts "*** #{validator.errors} validation errors found"
  exit 1
else
  puts "... Validation successful"
end
