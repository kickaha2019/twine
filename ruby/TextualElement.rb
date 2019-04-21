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

  def text
    @lines.collect {|l| (l == '') ? "\n\n" : l}.join( ' ').strip
  end

  def textual?
    true
  end
end
