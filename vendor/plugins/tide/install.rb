require 'fileutils'

#Copy the Model files
FileUtils.copy(Dir[File.dirname(__FILE__) + '/models/*.rb'], File.dirname(__FILE__) + '/../../../app/models/')

# copy the tide_path.yml file
tide_config = File.dirname(__FILE__) + '/../../../config/tide_path.yml'
unless File.exist?(tide_config)
  FileUtils.copy(File.dirname(__FILE__) + '/tide_path.yml.sample', tide_config)
end
