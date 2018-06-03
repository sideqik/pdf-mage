# frozen_string_literal: true

$mode = 'api'.freeze

require 'pdf_mage/init'
require 'pdf_mage/api/app'

module PdfMage
  def self.start!
    PdfMage::Api::App.run!
  end
end
