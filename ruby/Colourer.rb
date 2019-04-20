=begin
	Colourer.rb

	Organise worlds into colours such that worlds in a colour have a high number of
  common worlds goto-ing and goto-ing from.

  Try then to sort colours so for each world taking a goto
  to the world of the next colour will give a solution path that takes in
  all the worlds. In the case
  of there are no such gotos then the world has a goto to the Finish world.
=end

class Colourer

	def initialize( game)
    @game = game
    determine_worlds
    determine_world_linkage
    validate_scene_linkage
    @solutions = {}
  end

  def determine_world_linkage
    @world2worlds = Hash.new {|h,k| h[k] = {}}
    @world_entry = Hash.new {|h,k| h[k] = {}}

    ([@start] + @worlds.values).each do |world|
      world.scenes do |scene|
        scene.links do |gotos|
          gotos.each do |goto|
            if world != goto.goto.world
              @world2worlds[world.name][goto.goto.world.name] = goto.goto.world
              @world_entry[goto.goto.world.name][goto.goto.scene.name] = goto.goto.scene
            end
          end
        end
      end
    end

    @world_from_worlds = Hash.new {|h,k| h[k] = {}}
    @world2worlds.each_pair do |from, tos|
      tos.each_key do |to|
        @world_from_worlds[to][from] = (from == 'Start') ? @start : @worlds[from]
      end
    end
  end

  def determine_worlds
    @worlds = {}
    @game.worlds do |world|
      if world.name == 'Start'
        @start = world
      elsif world.name == 'Finish'
        @finish = world
      else
        @worlds[ world.name] = world
      end
    end
  end

  def duplicate?( colouration)
    key = colouration[0].collect do |colour|
      colour.collect {|w| w.name}.sort.join(',')
    end.join('-')

    return true if @solutions[key]
    @solutions[key] = colouration
    false
  end

  def errors( colouration)
    count, len = 0, colouration.size

    (0..(len-2)).each do |i|
      count += errors1( colouration[i], colouration[i+1])
    end
    count += errors1( colouration[len-2], colouration[1])

    count
  end

  def errors1( from, to)
    count = 0

    from.each do |from_world|
      reachable = @world2worlds[ from_world.name]

      to.each do |to_world|
        if reachable[ to_world.name].nil?
          count += 1
          from_world.suggest_goto( to_world)
        end
      end
    end

    count
  end

  def linked?( from, to)
    ! @world2worlds[ from.name][ to.name].nil?
  end

  def list_connects( world, io)
    @worlds.each_value do |to|
      if linked?( world, to)
        io.print ",YES"
      else
        io.print ","
      end
    end
    if linked?( world, @finish)
      io.print ",YES"
    else
      io.print ","
    end
    io.puts
  end

  def run( n_colours, n_samples, connects, scores)
    runs = []
    (0...n_samples).each do
      colouration = run_one( n_colours)
      runs << colouration if ! duplicate?( colouration)
    end

    runs.sort_by! {|run| run[1]}

    File.open( scores, 'w') do |io|
      io.print "score"
      (0...n_colours).each {|i| io.print ",#{i+1},"}
      io.puts

      runs[0...100].each do |run|
        score_col = run[1].to_s
        (0...@worlds_per_colour).each do |wi|
          io.print score_col

          (1..n_colours).each do |i|
            world = run[0][i][wi]
            io.print ",#{world.name}"

            targets = run[0][i+1]
            if i == n_colours
              targets = run[0][1] + targets
            end
            links = targets.collect do |target|
              linked?( world, target) ? 'Y' : 'N'
            end
            io.print ",#{links.join('')}"
          end

          score_col = ''
          io.puts
        end
      end
    end

    File.open( connects, 'w') do |io|
      io.print "from/to"
      @worlds.each_key {|name| io.print ",#{name}"}
      io.puts ",Finish"

      io.print "Start"
      list_connects( @start, io)

      @worlds.each_pair do |name, world|
        io.print "#{name}"
        list_connects( world, io)
      end
    end
  end

  def run_one( n_colours)
    raise "Number of worlds not divisible by #{n_colours}" if @worlds.size.modulo( n_colours) != 0
    @worlds_per_colour = @worlds.size / n_colours
    candidates = {}
    @worlds.each_key {|w| candidates[w] = 0}

    colouration = [[@start]]
    (0...n_colours).each {colouration << []}
    colouration << [@finish]

    (0...@worlds_per_colour).each do
      (0...n_colours).each do |c|
        froms = colouration[ 1 + ((c + n_colours - 1) % n_colours)]
        froms = [@start] + froms if c == 0
        tos = colouration[ 1 + ((c + 1) % n_colours)]
        tos = [@finish] + tos if c == (n_colours - 1)
        score_candidates( froms, tos, candidates)
        colouration[1+c] << @worlds[ select_candidate( candidates)]
      end
    end

    return colouration, errors( colouration)
  end

  def score_candidates( froms, tos, candidates)
    candidates.each_key {|w| candidates[w] = 0}

    froms.each do |from|
      candidates.each_key do |cand|
        candidates[cand] += 1 if @world2worlds[from.name][cand]
      end
    end

    tos.each do |to|
      candidates.each_key do |cand|
        candidates[cand] += 1 if @world2worlds[cand][to.name]
      end
    end
  end

  def select_candidate( candidates)
    best, max_count = [], 0
    candidates.each_value do |count|
      max_count = count if count > max_count
    end

    candidates.each_pair do |name, count|
      best << name if count == max_count
    end

    chosen = best[ rand( best.size)]
    candidates.delete( chosen)
    chosen
  end

  def validate_scene_linkage
    @worlds.each_pair do |world_name, world|
      scenes = {}
      world.scenes {|scene| scenes[scene.name] = scene}
      
      scenes.each_pair do |scene_name, scene|
        reachable = {}
        scenes.each_key {|n| reachable[n] = false}
        reachable[scene_name] = true
        
        world.links_from( scene) do |link|
          reachable[link.name] = true
        end

        reachable.each_pair do |rn, rl|
          if ! rl
            raise "#{world_name}:#{scene_name} cannot reach #{rn}"
          end
        end
      end
    end
  end
end
