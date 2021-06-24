# frozen_string_literal: true

require 'English'
require_relative 'base'
require_relative 'send_webhook'
require_relative 'upload_file'
require_relative 'render_pptx'
require 'securerandom'

module PdfMage
  module Workers
    # A Sidekiq job that renders a PDF using Chrome headless and kicks off post-render tasks, such as webhook
    # processing or uploading to Amazon S3.
    # @since 0.1.0
    class RenderPdf < PdfMage::Workers::Base
      def perform(website_url, final_format, callback_url, filename, meta, config)

        LOGGER.info "Rendering [#{website_url}] with callback [#{callback_url}] and meta: #{meta.inspect} and final format: #{final_format}"

        export_id = meta['export_id'] || SecureRandom.uuid
        LOGGER.info "[RenderPdf] generated export id #{export_id} ..."

        ensure_directory_exists_for_pdf(pdf_filename(export_id))
        url_with_secret = secretize_url(website_url)

        LOGGER.info "[RenderPdf] writing to file #{pdf_filename(export_id)}..."
        cmd = build_command(pdf_filename(export_id), url_with_secret, config)
        LOGGER.info "[RenderPdf] running command: #{cmd}"
        `#{cmd}`

        if CONFIG.optimize_pdf_size
          `
            mv #{pdf_filename(export_id)} #{pdf_filename(export_id)}.large;
            gs -sDEVICE=pdfwrite -dSAFER -dBATCH -dNOPAUSE -o #{pdf_filename(export_id)} -f #{pdf_filename(export_id)}.large
            rm #{pdf_filename(export_id)}.large;
          `
        end

        unless $CHILD_STATUS.exitstatus.zero?
          raise "Error executing chrome PDF export. Status: [#{$CHILD_STATUS.exitstatus}]"
        end

        LOGGER.info "Rendered PDF [#{export_id}] with status [#{$CHILD_STATUS.exitstatus}]"

        if final_format == 'pptx'
          PdfMage::Workers::RenderPptx.perform_async(export_id, callback_url, meta)
        elsif final_format == 'pdf'
          PdfMage::Workers::UploadFile.perform_async(pdf_filename(export_id), callback_url, meta)
        else
          raise ArgumentError, "unrecognized final format `#{final_format}`"
        end
      end

      def build_command(pdf_filename, url, config=nil)
        config = {} unless config.class == Hash

        delay = config.dig('delay')
        scale = config.dig('scale')

        "node ./print-to-pdf/index.js --path=\"#{pdf_filename}\" --url=\"#{url}\" --delay=\"#{delay.nil? ? 0 : delay.to_i}\" --scale=\"#{scale.nil? ? 1 : scale.to_f}\""
      end
    end
  end
end
