=begin
	ListAfters.rb

	List the different afters by from and to scenes


=end

require 'Parser.rb'

class ListAfters

	def initialize( game)
    @game = game
  end

  def list( io)
    io.puts "To world,To scene,From world,From scene,After"
    @game.worlds do |world|
      world.scenes do |scene|
        list_to( scene, io)
      end
    end
  end

  def list_to( to_scene, io)
    to_world_name, to_scene_name = to_scene.world.name, to_scene.name
    @game.worlds do |from_world|
      from_world.scenes do |from_scene|
        from_scene.choices do |choice|
          choice.results do |result|
            next if result.goto != to_scene
            if result.after
              io.puts "#{to_world_name},#{to_scene_name},#{from_scene.world.name},#{from_scene.name},#{result.after.line1}"
              to_world_name, to_scene_name = '', ''
            end
          end
        end
      end
    end
  end
end

game = Parser.new( ARGV[0]).parse

if game.errors > 0
  puts "*** #{game.errors} parse errors found"
  exit 1
else
  puts "... Parsing successful"
end

la = ListAfters.new( game)
File.open( ARGV[1], 'w') do |io|
  la.list( io)
end