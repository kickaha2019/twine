=begin
	Prompt.rb

	Prompt object which contains text
=end

class Prompt < TextualElement

	def initialize( indent, parent, file, lineno)
    super( indent, parent, file, lineno)
	end
end
