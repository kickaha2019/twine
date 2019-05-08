#
# Compile game into Tweego input file
#

class Compiler
  def initialize( game)
    @game = game
    @variables = {}
    @start = @game.world_by_name( 'Start').scene_by_name( 'Start')
    @finish = @game.world_by_name( 'Finish').scene_by_name( 'Finish')
    @numbering = Hash.new {|h,k| h[k] = 0}
  end

  def error( place, msg)
    @game.error( msg, place.file, place.lineno)
  end

  def errors
    @game.errors
  end

  def generate_choice_before( choice, io)
    return if choice.before.nil?
    io.print "<<if $c#{choice.number} >= 0>> "
    generate_text( choice.before, io)
    io.print "<</if>>"
  end

  def generate_choice_decide( choice, io)
    results = []
    choice.results {|result| results << result}

    # Set active choice result number
    io.print "<<set $c#{choice.number} = -1>>"
    (0...results.size).each do |i|
      result = results[-i-1]
      if result.goto && result.goto.world != choice.world
        if result.goto == @finish
          io.print "<<if $can_finish>>"
          io.print "<<set $c#{choice.number} = #{results.size-i}>>"
          io.print "<</if>>"
        else
          io.print "<<if not $w#{result.goto.world.number}>>"
          io.print "<<set $c#{choice.number} = #{results.size-i}>>"
          io.print "<</if>>"
        end
      else
        io.print "<<if (not $r#{result.number}) or ($c#{choice.number} < 0)>>"
        io.print "<<set $c#{choice.number} = #{results.size-i}>>"
        io.print "<</if>>"
      end
    end
  end

  def generate_choice_options( choice, io)
    results = []
    choice.results {|result| results << result}
    separ = choice.parent.choice_separator
    separ = '<BR>' if separ.nil?

    # Generate option buttons
    results.each_index do |i|
      result = results[i]
      io.print "<<if $c#{choice.number} is #{i+1}>><<button \""
      generate_text( choice.option, io)
      io.print "\" \"s#{result.goto ? result.goto.number : choice.parent.number}\">>"
      set_variable( 'result', result.text, io)
      set_variable( 'after', result.after, io) if result.after
      io.print "<<set $r#{result.number} = true>>"
      result.sets do |k,v|
        set_variable( "v#{@variables[k]}", v, io)
      end
      io.print "<</button>><<print \"#{separ}\">><</if>>"
    end
  end

  def generate_debug( io)
    @game.worlds do |world|
      if world.debug
        io.puts "DEBUG: World #{world.name} w#{world.number} = $w#{world.number}"
      end

      world.scenes do |scene|
        if scene.debug
          io.puts "DEBUG: Scene #{scene.name} s#{scene.number} = $s#{scene.number}"
        end

        if scene.dialogue
          scene.dialogue.each_pair do |_, resp|
            if resp.debug
              io.puts "DEBUG: File #{resp.file} Line #{resp.lineno} t#{resp.number} = $t#{resp.number}"
            end
          end
        end

        scene.choices do |choice|
          if choice.debug
            io.puts "DEBUG: File #{choice.file} Line #{choice.lineno} c#{choice.number} = $c#{choice.number}"
          end
          choice.results do |result|
            if result.debug
              io.puts "DEBUG: File #{result.file} Line #{result.lineno} r#{result.number} = $r#{result.number}"
            end
          end
        end
      end
    end
  end

  def generate_dialogue( dialogue, io)

    # Collect active dialogue options
    io.print "<<set _d_active = []>>"

    dialogue.each_pair do |_, answer|
      io.print "<<if ! $t#{answer.number}>>"
      io.print "<<run _d_active.push(#{answer.number})>>"
      io.print "<</if>>"
    end

    #io.print "<<print \"answer[17] = $answer[17]\">>"
    # Test for dialogue active - some options not taken yet
    io.print "<<if _d_active.length > 0>>"

    # Dialogue prompt
    if dialogue.prompt
      generate_text( dialogue.prompt, io)
      io.print "\n\n"
    end

    # First three dialogue options after shuffling
    io.print "<<run _d_active.shuffle()>>"
    io.print "<<for _i to 0; (_i < 3) && (_i < _d_active.length); _i++>>"
    io.print "<<set _d = _d_active[_i]>>"
    dialogue.each_pair do |option, answer|
      io.print "<<if _d is #{answer.number}>><<button \""
      generate_text( option, io)
      io.print "\" \"s#{dialogue.parent.number}\">>"
      io.print "<<set $t#{answer.number} = true>>"
      set_variable( 'result', answer, io)
      io.print "<</button>><<print \"<BR>\">><</if>>"
    end
    io.print "<</for>>"

    io.print "<<else>>"
  end

  def generate_ifid(io)
    io.puts <<"IFID"
:: StorySettings
ifid:#{@game.ifid}

IFID
  end

  def generate_literal( text, io)
    io.print '"' + replace_variables( text.text.strip).gsub( '"','\\"') + '"'
    # io.print '"' + replace_variables( text.text.strip).gsub( '"','\\"').gsub( "'","\\'") + '"'
  end

  def generate_scene( scene, io)
    if scene.name == 'Start'
      generate_setup( io)
    else
      io.puts "\n:: s#{scene.number}"
      io.print "<<set $w#{scene.parent.number} = true>>"
    end

    generate_debug( io)
    generate_test_finish( scene, io)

    io.print "<<if $result != \"\">><<print $result + \"\\n\\n\">><</if>>"

    img = scene.image ? scene.image : scene.world.image
    if img
      io.print "[img[#{img}]]"
      #io.print "<<print \"<DIV CLASS=\\\"image\\\"><IMG SRC=\\\"#{img}\\\"/></DIV>\">>"
    end

    scene.sets do |k,v|
      set_variable( "v#{@variables[k]}", v, io)
    end

    ntexts = 0
    scene.texts {|_| ntexts+=1}
    io.print "<<if $s#{scene.number} < #{ntexts}>>"
    io.print "<<set $s#{scene.number} += 1>>"
    io.print "<</if>>"

    ntexts = 0
    scene.texts do |text|
      ntexts += 1
      io.print "<<if $s#{scene.number} == #{ntexts}>>"
      generate_text( text, io)
      io.print "<</if>>"
    end

    scene.choices do |choice|
      generate_choice_decide( choice, io)
      generate_choice_before( choice, io)
    end

    io.print " $after\n\n"

    if scene.dialogue
      generate_dialogue( scene.dialogue, io)
    end

    if scene.prompt
      generate_text( scene.prompt, io)
      io.print "\n\n"
    end

    io.print "<<set $after = \"\">>"
    scene.choices do |choice|
      generate_choice_options( choice, io)
    end

    if scene.dialogue
      io.print "<</if>>"
    end
  end

  def generate_setup( io)
    io.print <<"START"
:: Start
<<if ndef $after>><<set $after = "">><<set $result = "">><<set $d_option=[]>><<set $d_response=[]>><<set $d_used=[]>>
START
    number_game_elements( io)
    # io.puts "<<goto s#{@game.world_by_name('Start').scene_by_name('Start').number}>>"
    io.print "<</if>>"
  end

  def generate_test_finish( scene, io)
    return if (scene == @finish) || (scene == @start)

    exits = []
    scene.world.scenes do |sibling|
      sibling.choices do |choice|
        choice.results do |result|
          if result.goto && (result.goto.world != scene.world) && (result.goto != @finish)
            exits << result.goto.world.number
          end
        end
      end
    end

    exits_tests = exits.uniq.collect {|en| "$w#{en}"}.join( " && ")
    io.print "<<set $can_finish = #{exits_tests}>>"
  end

  def generate_text( text, io)
    io.print replace_variables( text.text.strip)
  end

  def generate_title(io)
    io.puts <<"TITLE"
:: StoryTitle
#{@game.title}

TITLE
  end

  def new_element( array, initial_value, io)
    n = (@numbering[array] += 1)
    io.print "<<run $#{array}.push( #{initial_value})>>"
    n-1
  end

  def new_number( type, initial_value, io)
    n = (@numbering[type] += 1)
    io.print "<<set $#{type}#{n} = #{initial_value}>>"
    n
  end

  def number_game_elements( io)
    @game.worlds do |world|
      world.number = new_number( 'w', false, io)

      world.scenes do |scene|
        scene.number = new_number( 's', 0, io)

        if scene.dialogue
          scene.dialogue.each_pair do |option, response|
            response.number = new_number( 't', false, io)
          end
        end

        scene.choices do |choice|
          choice.number = new_number( 'c', 0, io)
          choice.results do |result|
            result.number = new_number( 'r', false, io)
            result.sets do |k,_|
              if @variables[k].nil?
                @variables[k] = new_number( 'v', '""', io)
              end
            end
          end
        end

        scene.sets do |k,_|
          if @variables[k].nil?
            @variables[k] = new_number( 'v', '""', io)
          end
        end
      end
    end
  end

  def replace_variables( ascii)
    ascii = ascii.split("\n")

    ascii.each_index do |i|
      while m = /^(.*)\${([^}]*)}(.*)$/.match( ascii[i]) do
        vnum = @variables[m[2]]
        if vnum
          ascii[i] = "#{m[1]}$v#{vnum}#{m[3]}"
        else
          error( text, "Undefined variable : #{m[2]}")
          break
        end
      end
    end

    ascii.join( "\n")
  end

  def run( output)
    File.open( output, 'w') do |io|
      generate_ifid( io)
      generate_title( io)
      generate_scene( @start, io)
      @game.worlds do |world|
        world.scenes do |scene|
          generate_scene( scene, io) if scene != @start
        end
      end
    end
  end

  def set_variable( var, value, io)
    value = value ? replace_variables( value.text) : ''
    io.print "<<set $#{var} = \"#{value.gsub('"','\\"').gsub("\n",'\\n')}\">>"
  end
end