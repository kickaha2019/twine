class Dialogue < Element
	attr_reader :prompt

	def initialize( parent, file, lineno)
    super( parent, file, lineno)
    @prompt = nil
    @options = []
    @responses = []
	end
  
  def add_option( indent, args, file, lineno)
    if args != ''
      error( 'Option has no parameters', file, lineno)
    end

    if @responses.size < @options.size
      error( 'Expecting a response', file, lineno)
    end

    @options << Text.new( indent, self, file, lineno)
    @options[-1]
  end

  def add_prompt( indent, args, file, lineno)
    if args != ''
      error( 'Prompt has no parameters', file, lineno)
    end

    if @prompt
      error( 'Prompt already defined for choice', file, lineno)
    end

    @prompt = Prompt.new( indent, self, file, lineno)
  end

  def add_response( indent, args, file, lineno)
    if args != ''
      error( 'Response has no parameters', file, lineno)
    end

    if @responses.size >= @options.size
      error( 'Expecting an option', file, lineno)
    end
    
    @responses << Text.new( indent, self, file, lineno)
    @responses[-1]
  end

  def each_pair
    @options.each_index do |i|
      yield @options[i], @responses[i]
    end
  end

  def validate
    error( "No prompt for dialogue") if @prompt.nil?
    error( "No options for dialogue") if @options.size == 0
    error( "Mismatch of options and responses") if @options.size != @responses.size
  end
end
