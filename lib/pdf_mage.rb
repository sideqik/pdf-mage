require 'god'
require 'pdf_mage/version'
require 'pdf_mage/api/app'

module PdfMage
  def self.start!
    trap('INT') do
      PdfMage.stop!
    end

    God.watch do |w|
      w.name = "simple"
      w.start = "ruby /full/path/to/simple.rb"
      w.keepalive
    end

    PdfMage::Api::App.run!
  end

  def self.stop!
    puts 'stoppin'
    exit
  end
end
