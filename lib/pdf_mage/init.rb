# frozen_string_literal: true

require 'logger'
require 'ostruct'
require 'yaml'

ENVIRONMENTS = %w[development test staging production].freeze

# Load Environment
current_env = ENV['PDFMAGE_ENV'] || 'development'
env_config = OpenStruct.new
env_config.current = current_env
ENVIRONMENTS.each { |env| env_config[env] = current_env == env }

# Load Config Files
user_config_filename = ENV['CONFIG_FILE'] ? File.expand_path(ENV['CONFIG_FILE']) : 'config.local.yml'
default_config_file  = File.new(File.expand_path('lib/pdf_mage/config.yml'))

# Build Configuration
config_hash = YAML.safe_load(default_config_file).to_h

if File.exist?(user_config_filename)
  user_config_file = File.new(user_config_filename)
  user_config      = YAML.safe_load(user_config_file).to_h
  config_hash      = config_hash.merge(user_config)
end

config      = OpenStruct.new(config_hash)
config.env  = env_config.freeze
CONFIG      = config.freeze

# Build Logger
LOGGER = Logger.new(STDOUT)
LOGGER.level = CONFIG.log_level
LOGGER.freeze
