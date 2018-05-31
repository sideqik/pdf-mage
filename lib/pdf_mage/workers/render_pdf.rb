require_relative 'base'
require_relative 'send_webhook'
require_relative 'upload_file'
require 'securerandom'

module PdfMage
  module Workers
    class RenderPdf < PdfMage::Workers::Base
      def perform(website_url, callback_url, meta)
        puts "Rendering [#{website_url}] with callback [#{callback_url}] and meta: #{meta.inspect}"
        pdf_id = SecureRandom.uuid
        pdf_filename = "#{$config.pdf_directory}/#{pdf_id}.pdf"
        %x[
          source ~/.bash_profile
          chrome --headless --disable-gpu --print-to-pdf=#{pdf_filename} #{website_url}
        ]

        if $config.aws_account_id
          PdfMage::Workers::UploadFile.perform_async(pdf_id, callback_url, meta)
        elsif callback_url
          PdfMage::Workers::SendWebhook.perform_async(callback_url, pdf_filename, meta)
        end
      end
    end
  end
end
