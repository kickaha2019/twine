class Result < Element
	attr_reader :after, :goto, :text
  attr_accessor :longest, :unvisited, :solution, :number

	def initialize( parent, file, lineno)
    super( parent, file, lineno)
    @text = nil
    @sets = {}
    @goto = nil
    @after = nil
    @solution = false
	end

  def add_after( indent, args, file, lineno)
    if args != ''
      error( 'After has no parameters', file, lineno)
    end

    if @after
      error( 'After already defined for result', file, lineno)
    end

    @after = Text.new( indent, self, file, lineno)
  end

  def add_goto( indent, args, file, lineno)
    if args == ''
      error( 'Goto has a parameter', file, lineno)
    end
    
    if @goto
      error( 'Result already has a goto', file, lineno)
    end
    
    @goto = args
    self
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

    if @text
      error( 'Text already defined for result', file, lineno)
    end

    @text = Text.new( indent, self, file, lineno)
  end

  def bind_gotos( game, world)
    return if @goto.nil?
    if m = /^(.*):(.*)$/.match( @goto)
      if (world1 = game.world_by_name(m[1])) && (scene = world1.scene_by_name(m[2]))
        @goto = scene
      else
        error( "Scene [#{@goto}] not found")
        @goto = nil
      end
    else
      if scene = world.scene_by_name(@goto)
        @goto = scene
      elsif (world1 = game.world_by_name(@goto)) && (scene1 = world1.scene_by_name(@goto))
        @goto = scene1
      else
        error( "Scene [#{@goto}] not found")
        @goto = nil
      end
    end
  end

  def choice
    parent
  end

  def scene
    parent.scene
  end

  def sets
    @sets.each_pair do |k, v|
      yield k, v
    end
  end

  def validate
    error( "No text or goto for result") if @text.nil? && @goto.nil?
  end

  def world
    parent.world
  end
end
