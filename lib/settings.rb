require 'yaml'

class Settings

  #--------------------------------------------------------------------------
  # this class allows us to create default and overrideable settings files.
  # I wanted to be able to have generic settings that would work for all
  # projects, one that allows a deployment system (like Chef) to be able to
  # inject specific settings just for that environment
  #
  # inspired by bundler's Settings class
  # https://github.com/carlhuda/bundler/blob/master/lib/bundler/settings.rb
  #--------------------------------------------------------------------------

  def initialize(root = nil)
    @root = root || Rails.root
    @default_config  = (File.exist?(default_config_file) && yaml = YAML.load_file(default_config_file)) ? yaml : {}
    @override_config = (File.exist?(override_config_file) && yaml = YAML.load_file(override_config_file)) ? yaml : {}

    # merge to create final config file
    @config = @default_config.extend(RecursiveMergeHash).rmerge(@override_config)
  end

  # mainly for testing
  def force_load_config(file)
    @config = File.exist?(file) && YAML.load_file(file)
  end

  def [](key)
    @config[key] ||
    (raise SettingsNotLoaded, ":#{key} not avaliable in settings files #{@default_config}, #{@override_config}")
  end

  def default_config_file
    Pathname.new("#{@root}/config/defaults.yml")
  end

  def override_config_file
    Pathname.new("#{@root}/config/specifics.yml")
  end

end

# I don't care to extend Hash for all instances, so I am just injecting this method for the
# config hashes inline and then extending all resulting hashes recursively
module RecursiveMergeHash
  # Taken from git://gist.github.com/6391.git
  def rmerge(other_hash)
    r = {}
    merge(other_hash) do |key, oldval, newval|
      r[key] = oldval.class == self.class ? oldval.extend(RecursiveMergeHash).rmerge(newval) : newval
    end
  end
end
