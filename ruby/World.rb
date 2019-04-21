=begin
	World.rb

	World object which contains scenes
=end

require 'Scene.rb'

class World < Element
	attr_reader :name, :suggested, :image
  attr_accessor :number
  
	def initialize( parent, name, indent, file, lineno)
    super( parent, indent, file, lineno)
		@name = name
    @image = nil
    @scenes = {}
    @suggested = Hash.new {|h,k| h[k] = 0}
	end

  def add_image( indent, args, file, lineno)
    if args == ''
      error( 'Image has a parameter', file, lineno)
    end

    if @image
      error( 'Image already defined for scene', file, lineno)
    end

    @image = args
    self
  end

  def add_scene( indent, args, file, lineno)
    if args == ''
      error( 'No name for scene', file, lineno)
      args = file + ':' + lineno.to_s
    end
    
    if @scenes[args.downcase]
      error( 'Duplicate scene name', file, lineno)
      args = file + ':' + lineno.to_s
    end
    
    @scenes[args.downcase] = Scene.new( self, args, indent, file, lineno)
  end

  def bind_gotos( game)
    @scenes.each_value do |scene|
      scene.bind_gotos( game, self)
    end
  end

  def final_links_from( scene, seen = {})
    if seen[scene.name].nil?
      seen[scene.name] = true
      scene.links do |results|
        final = nil
        results.each do |result|
          goto = result.goto
          final = (goto.world == self) ? goto : nil
        end

        if final
          yield final
          final_links_from( final, seen) do |link|
            yield link
          end
        end
      end
    end
  end

  def links_from( scene, seen = {})
    if seen[scene.name].nil?
      seen[scene.name] = true
      scene.links do |results|
        results.each do |result|
          goto = result.goto
          if goto.world == self
            yield goto
            links_from( goto, seen) do |link|
              yield link
            end
          end
        end
      end
    end
  end

  def scene_by_name(name)
    @scenes[name.downcase]
  end

  def scenes
    @scenes.each_value {|scene| yield scene}
  end

  def suggest_goto( world)
    @suggested[world.name] += 1
  end

  def validate
    @scenes.each_value {|scene| scene.validate}
  end
end
