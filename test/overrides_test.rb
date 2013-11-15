require 'bundler/setup' # if RUBY_VERSION < '1.9'

require 'overrides'

require 'minitest/autorun'

class OverridesTest < MiniTest::Unit::TestCase; end

class Ferko

  extend Overrides

  def kuk; 'ferko-kuk'; end
  def muk; 'ferko-muk'; end

  overrides
  def to_s
    'ferko' + super.to_s
  end

  def self.hoja; 'hoja-ferko'; end

end

OverridesTest.class_eval do

  def test_overrides_builtin_method
    assert Ferko.new.to_s
  end

  def test_methods_stay_the_same
    assert_equal 'ferko-kuk', Ferko.new.kuk
    assert_equal 'hoja-ferko', Ferko.hoja
  end

end

class Jozko < Ferko

  overrides
  def kuk; super; 'jozko-kuk'; end

  def muk; 'jozko-muk'; end
  def tuk; 'jozko-tuk'; end

  overrides :muk

end

OverridesTest.class_eval do

  def test_overrides_inherited_methods
    assert_equal 'jozko-kuk',  Jozko.new.kuk
    assert_equal 'jozko-muk',  Jozko.new.muk
    assert_equal 'jozko-tuk',  Jozko.new.tuk
  end

end

class Jozko

  overrides
  def self.hoja; super; 'hoja-jozko'; end

end

OverridesTest.class_eval do

  def test_overrides_singleton_method
    assert_equal 'hoja-jozko', Jozko.hoja
  end

end

class Janko < Ferko

  def kuk; super; 'janko-kuk'; end
  def muk; super; 'janko-muk'; end

  overrides :muk, :kuk

end

OverridesTest.class_eval do

  def test_overrides_multiple_at_once
    assert_equal 'janko-kuk',  Janko.new.kuk
    assert_equal 'janko-muk',  Janko.new.muk
  end

end

class Jozko

  def jak; 'jozko-jak'; end

end

OverridesTest.class_eval do

  def test_fails_when_override_not_met
    assert_raises NoMethodError do
      Jozko.class_eval do
        overrides :jak
      end
    end

    assert_raises NoMethodError do
      Jozko.class_eval do
        overrides
        def tak; end
      end
    end

    assert_raises NoMethodError do
      Jozko.class_eval do
        overrides
        def self.kuk; end
      end
    end
  end

end