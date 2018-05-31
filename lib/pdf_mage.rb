require 'pdf_mage/init'
require 'pdf_mage/version'
require 'pdf_mage/api/app'
require 'pdf_mage/workers/base'
require 'pdf_mage/workers/render_pdf'
require 'pdf_mage/workers/send_webhook'
require 'pdf_mage/workers/upload_file'

module PdfMage
  def self.start!
    PdfMage::Api::App.run!
  end
end
