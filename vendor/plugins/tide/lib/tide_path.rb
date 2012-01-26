module Tide
  
  class TidePathNotFoundException < StandardError #:nodoc:
  end
  
  # Manages the path to the tide executable for the different operating 
  # environments.
  class TidePath
    # Read the path for the current ENV
    unless File.exist?(RAILS_ROOT + '/config/tide_path.yml')
      raise TidePathNotFoundException.new("File RAILS_ROOT/config/tide_path.yml not found")
    else
      env = ENV['RAILS_ENV'] || RAILS_ENV
      TIDE_PATH = YAML.load_file(RAILS_ROOT + '/config/tide_path.yml')[env]
    end
    
    # Returns the path to the tide executable.
    def self.get
      TIDE_PATH
    end
  end
end

