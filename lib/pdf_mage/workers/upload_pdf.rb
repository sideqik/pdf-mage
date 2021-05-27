# frozen_string_literal: true

require_relative 'base'
require_relative 'send_webhook'
require_relative '../aws_helpers'
require_relative '../convert_api'
require 'aws-sdk-s3'

module PdfMage
  module Workers
    # A Sidekiq job that uploads a rendered PDF to Amazon S3.
    # @since 0.1.0
    class UploadPdf < PdfMage::Workers::Base
      include AwsHelpers

      def perform(export_id, callback_url = nil, meta = nil)
        validate_aws_config!

        s3 = Aws::S3::Resource.new(
          access_key_id: CONFIG.aws_account_key,
          region: CONFIG.aws_account_region,
          secret_access_key: CONFIG.aws_account_secret
        )

        s3_key = pdf_filename(export_id)
        obj = s3.bucket(CONFIG.aws_account_bucket).object(pdf_filename(export_id))
        obj.upload_file(pdf_filename(export_id))

        LOGGER.info "called bucket.object with argument #{export_id}"
        LOGGER.info "called obj.upload_file with argument #{pdf_filename(export_id)}"

        `rm #{pdf_filename(export_id)}` if CONFIG.delete_file_on_upload
        PdfMage::Workers::SendWebhook.perform_async(s3_key, callback_url, meta) if string_exists?(callback_url)
      end
    end
  end
end
