require 'pdf_mage/version'
require 'pdf_mage/api/app'

module PdfMage
  def self.start!
    PdfMage::Api::App.run!
  end
end
