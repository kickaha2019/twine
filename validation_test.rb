require 'minitest/autorun'
require 'minitest/reporters'
require 'Parser.rb'
require 'Validator.rb'

MiniTest::Reporters.use!

class ValidationTest < MiniTest::Test
  def test_all_worlds_reachable
    fire 'all_worlds_reachable'
  end

  def test_colours_same_size
    fire 'colours_same_size'
  end

  def test_fellow_scene_reachable
    fire 'fellow_scene_reachable'
  end

  def test_finish_not_reachable
    fire 'finish_not_reachable'
  end

  def test_finish_reachable
    fire 'finish_reachable'
  end

  def test_multiple_gotos
    fire 'multiple_gotos'
  end

  def test_next_scenes_always_reachable
    fire 'next_scenes_always_reachable'
  end

  def test_unexpected_reachable
    fire 'unexpected_reachable'
  end

  def fire( test)
    dir = nil
    $:.each do |inc|
      d = inc + '/tests/' + test
      dir = d if File.exist?( d)
    end

    assert( ! dir.nil?)
    File.open( '/tmp/output.txt', 'w') do |io|
      game = Parser.new( dir, io).parse
      if game.errors == 0
        validator = Validator.new( game)
        validator.run
      end
    end

    expected = IO.readlines( dir + '/expected.txt').join("\n").strip
    got = IO.readlines( '/tmp/output.txt').join("\n").strip

    assert_equal( expected, got)
  end
end