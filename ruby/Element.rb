=begin
	Element.rb

	Base class definitions
=end

class Element
  attr_reader :parent, :file, :lineno, :debug
  
  def initialize( parent, indent, file, lineno)
    @parent = parent
    @indent = indent
    @file   = file
    @lineno = lineno
    @debug  = false
  end
  
  def add_after( indent, args, file, lineno)
    @parent.add_after( indent, args, file, lineno)
  end

  def add_before( indent, args, file, lineno)
    @parent.add_before( indent, args, file, lineno)
  end

  def add_choice( indent, args, file, lineno)
    @parent.add_choice( indent, args, file, lineno)
  end

  def add_debug( indent, args, file, lineno)
    if args != ''
      error( 'Debug has no parameters', file, lineno)
    end
    @debug = true
    self
  end

  def add_dialogue( indent, args, file, lineno)
    @parent.add_dialogue( indent, args, file, lineno)
  end

  def add_goto( indent, args, file, lineno)
    @parent.add_goto( indent, args, file, lineno)
  end

  def add_prompt( indent, args, file, lineno)
    @parent.add_prompt( indent, args, file, lineno)
  end

  def add_response( indent, args, file, lineno)
    @parent.add_response( indent, args, file, lineno)
  end

  def add_result( indent, args, file, lineno)
    @parent.add_result( indent, args, file, lineno)
  end

  def add_scene( indent, args, file, lineno)
    @parent.add_scene( indent, args, file, lineno)
  end

  def add_set( indent, args, file, lineno)
    @parent.add_set( indent, args, file, lineno)
  end

  def add_text( indent, args, file, lineno)
    @parent.add_text( indent, args, file, lineno)
  end

  def error( msg, file=@file, lineno=@lineno)
    @parent.error( msg, file, lineno)
  end

  def indent
    @indent
  end

  def inspect
    "#{self.class.name}(#{@file}:#{@lineno})"
  end

  def textual?
    false
  end
  
  def add_world( indent, args, file, lineno)
    @parent.add_world( indent, args, file, lineno)
  end
end
