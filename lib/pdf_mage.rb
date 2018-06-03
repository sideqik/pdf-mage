# frozen_string_literal: true

MODE = 'api'.freeze

require 'pdf_mage/init'
require 'pdf_mage/api/app'

# Root loader for all PdfMage classes & modules
module PdfMage
  # Starts the PdfMage API Application
  # @return [NilClass]
  def self.start!
    PdfMage::Api::App.run!
    nil
  end
end
