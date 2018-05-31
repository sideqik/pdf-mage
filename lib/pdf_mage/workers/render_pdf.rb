require 'securerandom'

module PdfMage
  module Workers
    class RenderPdf < PdfMage::Workers::Base
      def perform(website_url, callback_url, meta)
        pdf_id = SecureRandom.uuid
        system("chrome --headless --disable-gpu --print-to-pdf=#{pdf_id}.pdf #{website_url}")

        if $config.aws_account_id
          UploadFile.perform_async(pdf_id, callback_url, meta)
        elsif callback_url
          SendWebhook.perform_async(callback_url, "#{pdf_id}.pdf", meta)
        end
      end
    end
  end
end
