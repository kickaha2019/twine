=begin
	Game.rb

	Root game object
=end

require 'World.rb'

class Game
	attr_reader :ifid, :title

	def initialize( log)
    @log = log
		@worlds = {}
    @errors = 0
    @ifid = nil
    @title = nil
	end

  def add_ifid( indent, args, file, lineno)
    @ifid = args
    self
  end

  def add_title( indent, args, file, lineno)
    @title = args
    self
  end

  def add_world( indent, args, file, lineno)
    if args == ''
      error( 'No name for world', file, lineno)
      args = file + ':' + lineno.to_s
    end
    
    if @worlds[args.downcase]
      error( 'Duplicate world name', file, lineno)
      args = file + ':' + lineno.to_s
    end
    
    @worlds[args.downcase] = World.new( self, args, file, lineno)
  end

  def bind_gotos
    @worlds.each_value do |world|
      world.bind_gotos( self)
    end
  end

  def error( msg, file, lineno)
    @errors += 1
    @log.puts "*** #{msg} at #{file}:#{lineno}"
  end
  
  def errors
    @errors
  end
  
  def indent
    ''
  end
  
#  def method_missing( verb, indent, args, file, lineno)
#    error( "Unhandled verb #{verb}", file, lineno)
#    self
#  end

  def non_terminal_worlds
    list = []
    worlds do |world|
      if world.name != 'Start' && world.name != 'Finish'
        list << world
      end
    end
    list
  end

  def textual?
    false
  end

  def validate
    @worlds.each_value {|world| world.validate}
  end

  def world_by_name(name)
    @worlds[name.downcase]
  end
  
  def worlds
    @worlds.each_value {|world| yield world}
  end
end
