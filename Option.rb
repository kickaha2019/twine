=begin
	Option.rb

	Option object which contains text
=end

class Option < TextualElement

	def initialize( indent, parent, file, lineno)
    super( indent, parent, file, lineno)
	end
end
