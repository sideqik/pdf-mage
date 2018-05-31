require 'pdf_mage'
require 'sidekiq'

module PdfMage
  module Workers
    class SampleWorker
      include Sidekiq::Worker

      def perform
        puts "Workin' hard!"
      end
    end
  end
end
