=begin
	Scene.rb

	Scene object which contains text and choices and dialogue
=end

require 'Choice.rb'
require 'Dialogue.rb'
require 'Assign.rb'
require 'Text.rb'

class Scene < Element
  attr_reader :name, :dialogue, :prompt, :image
  attr_accessor :number

	def initialize( parent, name, file, lineno)
    super( parent, file, lineno)
		@name = name
    @sets = {}
    @texts = []
    @choices = []
    @dialogue = nil
    @prompt = nil
    @image = nil
	end

  def add_choice( indent, args, file, lineno)
    if args != ''
      error( 'Choice has no parameters', file, lineno)
    end
    
    @choices << Choice.new( self, file, lineno)
    @choices[-1]
  end
  
  def add_dialogue( indent, args, file, lineno)
    if args != ''
      error( 'Dialogue has no parameters', file, lineno)
    end
    
    if @dialogue
      error( 'Scene already has a dialogue', file, lineno)
    end
    
    @dialogue = Dialogue.new( self, file, lineno)
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

  def add_prompt( indent, args, file, lineno)
    if args != ''
      error( 'Prompt has no parameters', file, lineno)
    end

    if @prompt
      error( 'Prompt already defined for scene', file, lineno)
    end

    @prompt = Prompt.new( indent, self, file, lineno)
  end

  def add_set( indent, args, file, lineno)
    if args == ''
      error( 'Set has name', file, lineno)
    end
    
    @sets[args] = Assign.new( indent, self, file, lineno)
  end

  def add_text( indent, args, file, lineno)
    if args != ''
      error( 'Text has no parameters', file, lineno)
    end
    
    @texts << Text.new( indent, self, file, lineno)
    @texts[-1]
  end

  def bind_gotos( game, world)
    @choices.each do |choice|
      choice.bind_gotos( game, world)
    end
  end

  def choices
    @choices.each do |choice|
      yield choice
    end
  end

  def links
    @choices.each do |choice|
      yield choice.links
    end
  end

  def scene
    self
  end

  def sets
    @sets.each_pair do |k, v|
      yield k, v
    end
  end

  def texts
    @texts.each do |text|
      yield text
    end
  end

  def validate
    if @texts.size == 0
      error( "No text for scene")
    end

    @choices.each {|choice| choice.validate}

    @dialogue.validate if @dialogue
  end

  def world
    @parent
  end
end
