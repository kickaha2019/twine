=begin
	Text.rb

	Text object which contains text
=end

class Text < TextualElement
	attr_accessor :number

	def initialize( indent, parent, file, lineno)
    super( indent, parent, file, lineno)
	end
end
