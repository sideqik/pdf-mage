# frozen_string_literal: true

require 'logger'
require 'ostruct'
require 'yaml'

ENVIRONMENTS = ['development', 'test', 'staging', 'production'].freeze

# Load Environment
current_env = ENV['PDFMAGE_ENV'] || 'development'
$env = OpenStruct.new()
$env.current = current_env
ENVIRONMENTS.each { |env| $env[env] = current_env == env }
$env.freeze

# Load Config Files
config_filename = ENV['CONFIG_FILE'] ? File.expand_path(ENV['CONFIG_FILE']) : nil
config_file = config_filename ? File.new(config_filename) : nil
default_config_file = File.new(File.expand_path('lib/pdf_mage/config.yml'))

# Build Configuration
default_config = YAML.load(default_config_file).to_h
user_config = config_file ? YAML.load(config_file).to_h : {}
config_hash = default_config.merge(user_config)
$config = OpenStruct.new(config_hash)
$config.freeze

# Build Logger
$logger = Logger.new('pdfmage.log')
$logger.level = $config.log_level
