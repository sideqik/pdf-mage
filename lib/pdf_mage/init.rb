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
config_filename = ENV['CONFIG_FILE'] ? File.expand_path(ENV['CONFIG_FILE']) : nil
config_file = config_filename ? File.new(config_filename) : nil
default_config_file = File.new(File.expand_path('lib/pdf_mage/config.yml'))

# Build Configuration
default_config = YAML.safe_load(default_config_file).to_h
user_config = config_file ? YAML.safe_load(config_file).to_h : {}
config_hash = default_config.merge(user_config)
config = OpenStruct.new(config_hash)
config.env = env_config.freeze
CONFIG = config.freeze

# Build Logger
LOGGER = Logger.new('pdfmage.log')
LOGGER.level = CONFIG.log_level
LOGGER.freeze
