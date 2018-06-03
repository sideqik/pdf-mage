require_relative 'base'
require_relative 'send_webhook'
require_relative 'upload_file'
require 'securerandom'

module PdfMage
  module Workers
    class RenderPdf < PdfMage::Workers::Base
      def perform(website_url, callback_url=nil, filename=nil, meta=nil)
        $logger.info "Rendering [#{website_url}] with callback [#{callback_url}] and meta: #{meta.inspect}"
        pdf_id = filename && !filename.empty? ? filename : SecureRandom.uuid
        ensure_directory_exists_for_pdf(pdf_filename(pdf_id))
        %x[#{$config.chrome_exe} --headless --disable-gpu --print-to-pdf=#{pdf_filename(pdf_id)} #{website_url}]

        if $config.aws_account_id
          PdfMage::Workers::UploadFile.perform_async(pdf_id, callback_url, meta)
        elsif callback_url && !callback_url.empty?
          PdfMage::Workers::SendWebhook.perform_async(pdf_filename(pdf_id), callback_url, meta)
        end
      end
    end
  end
end
