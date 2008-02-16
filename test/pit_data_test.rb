require 'test/unit'
require File.dirname(__FILE__) + '/test_helper.rb'

class PitDataTest < Test::Unit::TestCase
	def setup
		@data = Pit::Data.new({:foo => 'bar', :bar => 'baz' })
		@data2 = Pit::Data.new({"foo" => 'bar', "bar" => 'baz' })
	end

	def test_access_by_method
		assert_equal('bar', @data.foo)
		assert_equal('bar', @data2.foo)
		assert_equal('baz', @data.bar)
		assert_equal('baz', @data2.bar)
	end

	def test_access_by_brancket
		assert_equal('bar', @data[:foo])
		assert_equal('bar', @data["foo"])
		assert_equal('bar', @data2[:foo])
		assert_equal('bar', @data2["foo"])
		assert_equal('baz', @data[:bar])
		assert_equal('baz', @data["bar"])
		assert_equal('baz', @data2[:bar])
		assert_equal('baz', @data2["bar"])
	end

	def test_to_yaml
		assert_equal({"foo" => 'bar', "bar" => 'baz' }.to_yaml, @data.to_yaml)
		assert_equal({"foo" => 'bar', "bar" => 'baz' }.to_yaml, @data2.to_yaml)
	end
end
