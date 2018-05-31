require 'ostruct'
require 'yaml'

config_file = File.new(File.expand_path('lib/pdf_mage/config.yml'))
$config = OpenStruct.new(YAML.load(config_file)).freeze
