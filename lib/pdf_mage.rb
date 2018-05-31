require 'ostruct'
require 'yaml'
require 'pdf_mage/version'
require 'pdf_mage/api/app'

config_file = File.new(File.expand_path('lib/pdf_mage/config.yml'))
$config = OpenStruct.new(YAML.load(config_file)).freeze

module PdfMage
  def self.start!
    PdfMage::Api::App.run!
  end
end
