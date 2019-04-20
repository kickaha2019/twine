require 'Assign.rb'
require 'Option.rb'
require 'Prompt.rb'
require 'Result.rb'

class Choice < Element
	attr_reader :before, :option
  attr_accessor :number

	def initialize( parent, file, lineno)
    super( parent, file, lineno)
    @option = nil
    @before = nil
    @results = []
	end

  def add_before( indent, args, file, lineno)
    if args != ''
      error( 'Before has no parameters', file, lineno)
    end

    if @before
      error( 'Before already defined for choice', file, lineno)
    end

    @before = Text.new( indent, self, file, lineno)
  end

  def add_option( indent, args, file, lineno)
    if args != ''
      error( 'Option has no parameters', file, lineno)
    end

    if @option
      error( 'Option already defined for choice', file, lineno)
    end
    
    @option = Option.new( indent, self, file, lineno)
  end
  
  def add_result( indent, args, file, lineno)
    if args != ''
      error( 'Result has no parameters', file, lineno)
    end
    
    @results << Result.new( self, file, lineno)
    @results[-1]
  end

  def bind_gotos( game, world)
    @results.each do |result|
      result.bind_gotos( game, world)
    end
  end

  def links
    @results.collect do |result|
      # p ['Choice.gotos1', result.class, result.goto_scene.nil?]
      result
    end.select do |result1|
      not result1.goto.nil?
    end
  end

  def results
    @results.each {|result| yield result}
  end

  def scene
    parent.scene
  end

  def validate
    error( "No option for choice") if @option.nil?
    error( "No results for choice") if @results.size == 0
    @results.each {|result| result.validate}
  end

  def world
    parent.world
  end
end
