=begin
	Parser.rb

	Return parse tree from game data files
=end

require 'Element.rb'
require 'TextualElement.rb'
require 'Game.rb'

class Parser
	
	def initialize( dir, log=nil, debug=nil)
		@dir = dir
    @log = log ? log : STDOUT;
    @debug = debug ? Regexp.new( debug) : nil
    @game = Game.new( @log)
	end
  
  def debug( msg, line, args={})
    return false if @debug.nil?
    if @debug =~ line
      @log.puts "... #{msg}: #{line}"
      args.each_pair do |k,v|
        @log.puts "      #{k}=#{v}"
      end
      true
    else
      false
    end
  end
  
  def parse
    Dir.entries( @dir).each do |f|
      if /\.sh$/ =~ f
        parse_file( f)
      end
    end
    
    if @game.errors == 0
      @game.bind_gotos
    end
    
    @game
  end
  
  def parse_file( f)
    lines, parent = IO.readlines( @dir + '/' + f), @game
    
    lines.each_index do |i|
      line = lines[i].chomp
      next if /^\s*#/ =~ line
      debug( "parse_file1", line, parent:parent)

      if m = /^(\s*)(\S.*)$/.match( line)
        debug( "parse_file2", line)
        indent, text = m[1], m[2]

        while (indent.size <= parent.indent.size) && (parent.indent != '')
          parent = parent.parent
        end

        if (indent.size > 0) && parent.textual?
          debug( "parse_file3", line)
          parent.add_text( text)
        else
          debug( "parse_file4", line)
          if m = /^(\w+)((\s.*$|$))/.match( text)
            debug( "parse_file5", line)
            begin
              parent = parent.parent if parent.textual?
              parent = parent.send( ('add_' + m[1]).to_sym, indent, m[2].strip, f, i+1)
            rescue Exception => bang
              @game.error( bang.message, f, i+1)
              parent = @game
            end
          else
            parent.error( 'Syntax error', f, i+1)
          end
        end
      elsif parent.textual?
        debug( "parse_file6", line)
        parent.add_text( '')
      end
      
      raise "Debugging" if debug( "parse_file7", line, parent:parent)
    end
  end
end
