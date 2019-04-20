require 'Compiler.rb'
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

compiler = Compiler.new( game)
compiler.run( ARGV[1])

if compiler.errors > 0
  puts "*** #{compiler.errors} compiler errors found"
  exit 1
else
  puts "... Compilation successful"
end
