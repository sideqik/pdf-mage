# frozen_string_literal: true

require_relative 'base'
require_relative 'send_webhook'
require_relative '../convert_api'
require 'aws-sdk-s3'
require 'open-uri'

module PdfMage
  module Workers
    class UploadPptx < PdfMage::Workers::Base
      include AwsHelpers

      def perform(export_id, callback_url = nil, meta = nil)
        LOGGER.info "Uploading pptx file [#{pptx_filename(export_id)}] with callback [#{callback_url}] and meta: #{meta.inspect}}"

        validate_aws_config!

        s3 = Aws::S3::Resource.new(
          access_key_id: CONFIG.aws_account_key,
          region: CONFIG.aws_account_region,
          secret_access_key: CONFIG.aws_account_secret
        )

        s3_key = pptx_filename(export_id)
        obj = s3.bucket(CONFIG.aws_account_bucket).object(pptx_filename(export_id))
        obj.upload_file(pptx_filename(export_id))

        LOGGER.info "called bucket.object with argument #{export_id}"
        LOGGER.info "called obj.upload_file with argument #{pptx_filename(export_id)}"

        if CONFIG.delete_file_on_upload
          `rm #{pptx_filename(export_id)}`
        end

        if string_exists?(callback_url)
          LOGGER.info("Sending webhook to callback...")
          PdfMage::Workers::SendWebhook.perform_async(s3_key, callback_url, meta)
        end
      end
    end
  end
end
