=begin
	Viewer.rb

	View game at the terminal
=end

class Viewer

	def initialize( game)
    @game = game
    @visited = []
    @after = nil

    @worlds = @game.non_terminal_worlds

    if (start_world = @game.world_by_name('Start')).nil?
      raise "No start world found"
    end

    if (start_scene = start_world.scene_by_name('Start')).nil?
      raise "No start scene found"
    end

    @scene = start_scene
    @assigns = {}
  end

  def assign( k, v)
    @assigns[k] = v
  end

  def load_scene

    # Load sets from scene
    @scene.sets {|k,v| assign( k, v)}

    # Text from scene itself
    scene_text = nil
    @scene.texts do |text|
      if scene_text.nil? or scene_text.used
        scene_text = text
      end
    end

    @text = []
    if scene_text
      @text << scene_text
      scene_text.used = true
    end

    # Add previous after if any
    @text << @after if @after

    # Work out possible dialogue
    @options = []
    if @scene.dialogue
      @scene.dialogue.each_pair do |prompt, response|
        if not prompt.used
          @options << [prompt, response]
        end
      end
    end

    # Work out possible results
    @scene.choices do |choice|
      choice.results do |result|
        if possible( result)
          @options << result

          # Add before from result to text
          if before = result.choice.before
            @text << before
          end

          break
        end
      end
    end
  end

  def output( text)
    line = text.text
    while m = /^(.*)\$\{([^\}]*)\}(.*)$/.match( line)
      els = [m[1]]
      els << (@assigns[m[2]] ? @assigns[m[2]].text : '???')
      els << m[3]
      line = els.join('')
    end
    print line
  end

  def possible( result)
    return true if result.goto.nil?
    return true if result.goto.world == @scene.world
    return false if (result.goto.world.name == 'Finish') && (@visited.size < @worlds.size)
    return ! @visited.include?( result.goto.world)
  end

  def realise
    separ = ''
    @text.each  do |text|
      print separ
      output( text)
      separ = ' '
    end
    puts "\n"

    i = 0
    @options.each do |option|
      puts if i == 0
      i += 1
      print "#{i}: "
      if option.is_a?( Result)
        output( option.choice.prompt)
      else
        output( option[0])
      end
      puts
    end
    puts
  end

  def run( entries)
    entries.reverse!
    load_scene

    while @options.size > 0
      realise

      print "Choice? "
      if entries.size > 0
        input = entries.pop
        puts
      else
        input = STDIN.gets.strip
      end

      puts
      if ! /^\d+$/ =~ input
        next
      end

      chosen = input.to_i - 1

      if (chosen >= 0) && (chosen < @options.size)
        result = @options[chosen]
        if result.is_a?( Result)
          result.sets {|k, v| assign( k, v)}

          if text = result.text
            output( text)
            print ' '
          end

          @after = @options[chosen].after
          if scene = @options[chosen].goto
            if @scene.world != scene.world
              @visited << scene.world
            end

            @scene = scene
          end
        else
          prompt, response = * result
          prompt.used = true
          output( response)
          puts
        end
      end

      load_scene
    end

    realise
  end
end
