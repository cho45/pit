require "tmpdir"
require "pathname"

class Pathname
	@@tempname_number = 0
	def self.tempname(base=$0, dir=Dir.tmpdir)
		@@tempname_number += 1
		path = new(dir) + "#{File.basename(base)}.#{$$}.#{@@tempname_number}"
		at_exit do
			path.rmtree if path.exist?
		end
		path
	end
end

dir  = Pathname.tempname
dir.mkpath
ENV["HOME"] = dir

require File.dirname(__FILE__) + '/test_helper.rb'

require "test/unit"
class PitTest < Test::Unit::TestCase
	def test_load
		assert Pit
	end

	def test_set_get
		Pit.set("test", :data => {"username"=>"foo","password"=>"bar"})
		assert_equal "foo", Pit.get("test")["username"]
		assert_equal "bar", Pit.get("test")["password"]

		Pit.set("test2", :data => {"username"=>"foo2","password"=>"bar2"})
		assert_equal "foo2", Pit.get("test2")["username"]
		assert_equal "bar2", Pit.get("test2")["password"]

		Pit.set("test", :data => {"username"=>"foo","password"=>"bar"})
		assert_equal "foo", Pit.get("test")["username"]
		assert_equal "bar", Pit.get("test")["password"]

		assert_equal "foo", Pit.set("test", :data => {"username"=>"foo","password"=>"bar"})["username"]
	end

	def test_set_get_with_method
		Pit.set("test", :data => {"username"=>"foo","password"=>"bar"})
		assert_equal("foo", Pit.get("test").username)
		assert_equal("bar", Pit.get("test").password)

		Pit.set("test2", :data => {"username"=>"foo2","password"=>"bar2"})
		assert_equal("foo2", Pit.get("test2").username)
		assert_equal("bar2", Pit.get("test2").password)

		assert_equal("foo", Pit.set("test", :data => {"username"=>"foo","password"=>"bar"}).username)
	end

	def test_editor
		# clear
		Pit.set("test", :data => {})

		ENV["EDITOR"] = nil
		assert_nothing_raised("When editor is not set.") do
			Pit.set("test")
		end

		tst = Pathname.tempname
		exe = Pathname.tempname
		exe.open("w") do |f|
			f.puts <<-EOF.gsub(/^\t+/, "")
				#!/usr/bin/env ruby

				File.open(ENV["TEST_FILE"], "w") do |f|
					f.puts ARGF.read
				end
			EOF
		end
		exe.chmod(0700)

		ENV["TEST_FILE"] = tst.to_s
		ENV["EDITOR"]    = exe.to_s
		Pit.set("test")

		assert_nothing_raised do
			assert_equal({}, YAML.load_file(tst.to_s))
		end

		data = {
			"foo" => "0101",
			"bar" => "0202",
		}

		Pit.set("test", :data => data)
		Pit.set("test")

		assert_nothing_raised do
			assert_equal(data, YAML.load_file(tst.to_s))
		end

    # testing with data key symbol
		data = {
			:foo => "0101",
			:bar => "0202",
		}

		Pit.set("test", :data => data)
		Pit.set("test")

		expected_of = {
			"foo" => "0101",
			"bar" => "0202", 
		}

		assert_nothing_raised do
			assert_equal(expected_of, YAML.load_file(tst.to_s), "when data has Symbol key, it convet to String for portability of language")
		end

		# clear
		Pit.set("test", :data => {})
		tst.open("w") {|f| }

		Pit.get("test", :require => data)

		assert_nothing_raised do
			assert_equal(expected_of, YAML.load_file(tst.to_s))
		end
	end

	def test_switch
		Pit.switch("default")
		Pit.set("test", :data => {"username"=>"foo","password"=>"bar"})
		assert_equal "foo", Pit.get("test")["username"]
		assert_equal "bar", Pit.get("test")["password"]

		r = Pit.switch("profile2")
		assert_equal "default", r
		assert_equal "profile2", Pit.config["profile"]
		Pit.set("test", :data => {"username"=>"foo2","password"=>"bar2"})
		assert_equal "foo2", Pit.get("test")["username"]
		assert_equal "bar2", Pit.get("test")["password"]

		Pit.switch("default")
		Pit.set("test", :data => {"username"=>"foo","password"=>"bar"})
		assert_equal "foo", Pit.get("test")["username"]
		assert_equal "bar", Pit.get("test")["password"]
	end
end
