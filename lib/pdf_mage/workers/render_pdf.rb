# frozen_string_literal: true

require_relative 'base'
require_relative 'send_webhook'
require_relative 'upload_file'
require 'securerandom'

module PdfMage
  module Workers
    # A Sidekiq job that renders a PDF using Chrome headless and kicks off post-render tasks, such as webhook
    # processing or uploading to Amazon S3.
    # @since 0.1.0
    class RenderPdf < PdfMage::Workers::Base
      def perform(website_url, callback_url = nil, filename = nil, meta = nil)
        LOGGER.info "Rendering [#{website_url}] with callback [#{callback_url}] and meta: #{meta.inspect}"

        stripped_filename = strip_string(filename)
        stripped_filename_present = string_exists?(stripped_filename)

        # If a filename exists and the stripped version causes the string to be empty, warn about it in the logs.
        if filename && !stripped_filename_present
          LOGGER.warn "'#{filename}' is not a valid ASCII string, falling back to UUID for PDF name."
        end

        pdf_id = stripped_filename_present ? stripped_filename : SecureRandom.uuid
        ensure_directory_exists_for_pdf(pdf_filename(pdf_id))

        url_with_secret = secretize_url(website_url)

        `#{CONFIG.chrome_exe} --headless --disable-gpu --print-to-pdf=#{pdf_filename(pdf_id)} #{url_with_secret}`

        if CONFIG.aws_account_key
          PdfMage::Workers::UploadFile.perform_async(pdf_id, callback_url, meta)
        elsif string_exists?(callback_url)
          PdfMage::Workers::SendWebhook.perform_async(pdf_filename(pdf_id), callback_url, meta)
        end
      end
    end
  end
end
