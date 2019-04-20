=begin
	Validator.rb

	Validate that the worlds are organised like:

    Start
    Worlds 1a 1b ...
    Worlds 2a 2b ...
    ...
    Worlds Na Nb ...
    Finish

  such that there are the same number of worlds for groups 1 2 up to N,
  that Start links to only worlds in group 1, that group 1 .. (N-1) worlds
  link to all worlds in the next group and only those worlds,
  that worlds in group N link both to Finish, and to all worlds in group 1,
  and only those worlds.

  Validate that from any scene in a world all other scenes in that
  world can be reached or a link to the next group of worlds.

  Validate that no choice has links to multiple worlds.
=end

class Validator

	def initialize( game)
    @game = game
    @start = nil
    @finish = nil
    determine_worlds
    determine_world_linkage
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

  def error( place, msg)
    @game.error( msg, place.file, place.lineno)
  end

  def errors
    @game.errors
  end

  def extend( colour)
    extent = []

    colour.each do |world|
      @world2worlds[world.name].each_key do |link|
        extent << link if @worlds[link]
      end
    end

    extent.uniq.collect {|w| @worlds[w]}
  end

  def run
    if @start.nil?
      error( @game, "No start world")
      return
    end

    if @finish.nil?
      error( @game, "No finish world")
      return
    end

    validate_scene_linkage
    validate_grouping
    validate_next_scenes_reachable
    validate_only_next_reachable
    validate_unique_gotos

    @game.validate
  end

  def validate_can_reach( froms, tos)
    froms.each do |from|
      tos.each do |to|
        if (from != to) && @world2worlds[from.name][to.name].nil?
          error( from, "Cannot reach #{to.name}")
        end
      end
    end
  end

  def validate_grouping
    @groups = []
    @world_groups = {}
    @ungrouped = @worlds.size

    while @ungrouped > 0
      base = @groups[-1] ? @groups[-1] : [@start]
      group = extend( base)

      if group.size == 0
        error( base[0], "Not all worlds reachable")
        break
      end

      @ungrouped -= group.size
      @groups << group
      group.each {|w| @world_groups[w] = @groups.size}
    end

    (1...@groups.size).each do |i|
      if @groups[i-1].size != @groups[i].size
        error( @groups[i][0], "Inconsistent colour size")
      end
    end
  end

  def validate_next_scenes_reachable
    validate_can_reach( [@start], @groups[0])
    (0..(@groups.size-2)).each do |i|
      validate_can_reach( @groups[i], @groups[i+1])
    end
    validate_can_reach( @groups[-1], @groups[0] + [@finish])
  end

  def validate_only_next_reachable
    validate_only_reach( [@start], @groups[0])
    (0..(@groups.size-2)).each do |i|
      validate_only_reach( @groups[i], @groups[i+1])
    end
    validate_only_reach( @groups[-1], @groups[0] + [@finish])
  end

  def validate_only_reach( froms, tos)
    froms.each do |from|
      from.scenes do |scene|
        scene.links do |links|
          links.each do |link|
            if link.goto && link.goto.world != from
              if ! tos.include?( link.goto.world)
                error( from, "Can reach #{link.goto.world.name}")
              end
            end
          end
        end
      end
      # @world2worlds[from.name].values do |r|
      #   if ! tos.include?( r)
      #     error( from, "Can reach #{r.name}")
      #   end
      # end
    end
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
            error( scene, "#{world_name}:#{scene_name} cannot reach #{rn}")
          end
        end
      end
    end
  end

  def validate_unique_gotos
    ([@start] + @worlds.values).each do |world|
      world.scenes do |scene|
        scene.choices do |choice|
          jump = nil
          choice.results do |result|
            #if result.goto && (result.goto.world != world) && (result.goto.world != @finish)
            if result.goto && (result.goto.world != @finish)
              if (! jump.nil?) && (jump.goto != result.goto)
                error( result, "Multiple gotos for a choice")
              end
              jump = result
            end
          end
        end
      end
    end
  end
end
