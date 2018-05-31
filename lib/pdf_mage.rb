require 'ostruct'
require 'yaml'
require 'pdf_mage/version'
require 'pdf_mage/api/app'
require 'pdf_mage/workers/base'
require 'pdf_mage/workers/render_pdf'
require 'pdf_mage/workers/send_webhook'
require 'pdf_mage/workers/upload_file'

config_file = File.new(File.expand_path('lib/pdf_mage/config.yml'))
$config = OpenStruct.new(YAML.load(config_file)).freeze

module PdfMage
  def self.start!
    PdfMage::Api::App.run!
  end
end
