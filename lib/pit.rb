
require "yaml"
require "pathname"
require "tempfile"

module Pit
	VERSION   = "0.0.6"
	Directory = Pathname.new("~/.pit").expand_path
	@@config  = Directory + "pit.yaml"
	@@profile = Directory + "default.yaml"

	# Set _name_ setting to current profile.
	# If not _opts_ specified, this opens $EDITOR with current profile setting.
	# If `data` specified, this just sets it to current profile.
	# If `config` specified, this opens $EDITOR with merged hash with specified hash and
	# current profile.
	def self.set(name, opts={})
		profile = self.load
		if opts.key?(:data)
			result = opts[:data]
		else
			if ENV["EDITOR"].nil? || !$stdout.tty?
				return {}
			end
			c = (opts[:config] || self.get(name)).to_yaml
			t = Tempfile.new("pit")
			t << c
			t.close
			system(ENV["EDITOR"], t.path)
			t.open
			result = t.read
			if result == c
				warn "No Changes"
				return profile[name]
			end
			result = YAML.load(result)
		end
		profile[name] = result
		@@profile.open("w") {|f| YAML.dump(profile, f) }
		result
	end

	# Get _name_ setting from current profile.
	# If not _opts_ specified, this just returns setting from current profile.
	# If _require_ specified, check keys on setting and open $EDITOR.
	def self.get(name, opts={})
		ret = self.load[name] || {}
		if opts[:require]
			unless opts[:require].keys.all? {|k| ret[k] }
				ret = opts[:require].update(ret)
				ret = self.set(name, :config => ret)
			end
		end
		ret || {"username"=>"", "password"=>""}
	end

	# Switch to current profile to _name_.
	# Profile is set of settings. You can switch some settings using profile.
	def self.switch(name, opts={})
		@@profile = Directory + "#{name}.yaml"
		config = self.config
		ret = config["profile"]
		config["profile"] = name
		@@config.open("w") {|f| f << config.to_yaml }
		ret
	end

	protected
	def self.load
		Directory.mkpath unless Directory.exist?
		Directory.chmod 0700
		unless @@config.exist?
			@@config.open("w") {|f| f << {"profile"=>"default"}.to_yaml }
			@@config.chmod(0600)
		end
		self.switch(self.config["profile"])
		unless @@profile.exist?
			@@profile.open("w") {|f| f << {}.to_yaml }
			@@profile.chmod(0600)
		end
		YAML.load(@@profile.read) || {}
	end

	def self.config
		YAML.load(@@config.read)
	end
end


__END__
p Pit.set("test")
p Pit.get("test")

config = Pit.get("twitter")
p config["password"]
p config["username"]

