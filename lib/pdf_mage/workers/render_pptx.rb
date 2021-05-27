# frozen_string_literal: true

require_relative 'base'
require_relative 'send_webhook'
require_relative '../convert_api'
require 'aws-sdk-s3'
require 'open-uri'

module PdfMage
  module Workers
    class RenderPptx < PdfMage::Workers::Base

      def perform(export_id, callback_url = nil, meta = nil)
        LOGGER.info "Converting [#{export_id}] with callback [#{callback_url}] and meta: #{meta.inspect}}"

        capi_file_id = ConvertApi.upload_file(pdf_filename(export_id))
        conversion_result = ConvertApi.convert(capi_file_id, from: 'pdf', to: 'pptx')

        if conversion_result.length > 1
          raise 'Unexpectedly received multiple files from ConvertAPI'
        end
        pptx_url = conversion_result.first

        LOGGER.info "[RenderPptx] opening file #{pptx_filename(export_id)} for binary write..."
        pptx_file = File.open(pptx_filename(export_id), 'wb')
        IO.copy_stream(open(pptx_url), pptx_file)

        if CONFIG.delete_file_on_upload
          `rm #{pdf_filename(export_id)}`
        end

        LOGGER.info "Rendered PPTX [#{pptx_filename(export_id)}] for PDF [#{export_id}]"

        if CONFIG.aws_account_key
          PdfMage::Workers::UploadPptx.perform_async(export_id, callback_url, meta)
        elsif string_exists?(callback_url)
          PdfMage::Workers::SendWebhook.perform_async(pptx_filename(export_id), callback_url, meta)
        end
      end
    end
  end
end
