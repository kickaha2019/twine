=begin
	TextualElement.rb

	Element object which contains text
=end

class TextualElement < Element
  attr_accessor :used

	def initialize( indent, parent, file, lineno)
    super( parent, indent, file, lineno)
    @lines = []
    @used = false

    while @lines[-1] == '' do
      @lines = @lines[0...-1]
    end
	end

  def add_text( line)
    @lines << line
  end

  def line1
    @lines[0]
  end

  def text
    while @lines[-1] == '' do
      @lines = @lines[0...-1]
    end

    joined = @lines.collect {|l| (l == '') ? "\n\n" : l}.join( ' ').strip

    joined.gsub( '\\t', "&nbsp;&nbsp;&nbsp;&nbsp;").gsub( '\\n', "\n").gsub( "\n ", "\n").gsub( "\n\n\n", "\n\n")
  end

  def textual?
    true
  end
end
