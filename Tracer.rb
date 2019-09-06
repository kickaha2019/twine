=begin
	Tracer.rb

	Trace paths through game that touch all the worlds
=end

class Tracer
	attr_reader :solution_count
  
  class Point
    attr :origin, :scene
    
    def initialize( origin, scene, results, width)
      @origin = origin
      @scene = scene
      @results = results
      @index = -1
      if @results.size > 0
        div, mod = * width.divmod( @results.size)
        @widths = @results.collect {div}
        (0...mod).each {|i| @widths[i] += 1}
        @widths.shuffle!
      end
    end
    
    def possible
      @index += 1
      while @index < @results.size
        return @results[@index], @results[@index].goto, @widths[@index] if @widths[@index] > 0
        @index += 1
      end
      return nil, nil, 0
    end

    def world
      w = @scene
      while ! w.is_a?( World)
        w = w.parent
      end
      w
    end
  end
  
	def initialize( game, width)
    @game = game
    @worlds_hit = {}
    @solution_count = 0
    
    # Initialise times we're in each world
    @game.worlds do |world|
      @worlds_hit[ world.name] = 0
    end
    @worlds_hit[ 'Start'] = 1

    if (start_world = @game.world_by_name('Start')).nil?
      raise "No start world found"
    end

    if (start_scene = start_world.scene_by_name('Start')).nil?
      raise "No start scene found"
    end

    # Initialise path
    @path = []
    @path << Point.new( nil, start_scene, possibles( start_scene), width)
	end

  def extend( origin, node, width, io)
    # if situation?( 'Arctic', 'Claus', 22)
    #   puts "DEBUG100"
    # end

    # Reached Finish world?
    if node.world.name == 'Finish'
      last = nil
      @path.each do |point|
        point.origin.solution = true if point.origin
        io.print "," if ! last.nil?
        io.print "#{point.world.name}:#{point.scene.name}"
        last = point
      end

      io.puts ",#{node.world.name}:#{node.scene.name}"
      @solution_count += 1
      return false
    end

    results = possibles( node)
    return false if results.size == 0

    @path << Point.new( origin, node, results, width)
    @worlds_hit[ node.world.name] += 1

    true
  end

  def possibles( scene)
    valid = []
    @worlds_hit[ scene.world.name] += 1

    scene.links do |results|
      results = results.select do |result|
        ok = true
        goto = result.goto
        
        # Prevent return to same scene during trace
        i = @path.size-1
        while ok && (i >= 0) && (@path[i].world == goto.world) do
          ok = false if @path[i].scene == goto
          i -= 1
        end
      
        # Prevent reaching Finish while intermediate worlds not visited
        if ok && (goto.world.name == 'Finish')
          @worlds_hit.each_pair do |name, hits|
            if (name != 'Finish') && (hits == 0)
              ok = false
              break
            end
          end
        end
      
        # Prevent revisiting already visited world
        if ok && @path[-1] && (goto.world != @path[-1].world)
          ok = false if @worlds_hit[ goto.world.name] > 0
        end

        ok
      end
      
      valid << results[0] if results.size > 0
    end

    @worlds_hit[ scene.world.name] -= 1
    valid
  end

  def retract( origin, node = nil)
    longest = @path.collect {|node| [node.world.name, node.scene.name]}
    longest << [node.world.name, node.scene.name] if not node.nil?

    unvisited = []
    @worlds_hit.each_pair do |name, hits|
      unvisited << name if (hits == 0) && (name != 'Finish') && (node.nil? || (node.name != name))
    end

    origins = @path.collect {|p| p.origin}
    (origins + [origin]).each do |o|
      if o && (o.longest.nil? || (o.longest.size < longest.size))
        o.longest = longest
        o.unvisited = unvisited
      end
    end
    
    old = @path.pop
    @worlds_hit[ old.world.name] -= 1
    old
  end

  def situation?( world_name, scene_name, path_length)
    return false if @path[-1].nil?
    return false if @path.size < path_length
    return false if @path[-1].world.name != world_name
    return false if @path[-1].scene.name != scene_name
    true
  end

  def trace( solutions_output, longest_output)
    File.open( solutions_output, 'w') do |io|
      io.puts 'Solutions'
      while @path.size > 0 do
        origin, node, width = * @path[-1].possible
        if node
          if not extend( origin, node, width, io)
            retract( origin, node)
          end
        else
          retract( origin)
        end
      end
    end
    
    File.open( longest_output, 'w') do |io|
      io.puts 'Origin,Distance'
      @game.worlds do |world|
        world.scenes do |scene|
          scene.choices do |choice|
            choice.results do |result|
              if result.goto && (! result.solution)
                io.print "#{result.file}:#{result.lineno},"

                if result.longest
                  walked = result.longest.collect {|s| ",#{s[0]}:#{s[1]}"}.join('')
                  io.print "#{result.longest.size}#{walked}"
                  result.unvisited.each do |w|
                    io.print ",,#{w}"
                  end
                else
                  io.print '0'
                end

                io.puts
              end
            end
          end
        end
      end
    end
  end
end
