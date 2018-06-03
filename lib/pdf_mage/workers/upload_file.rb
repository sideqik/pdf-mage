require_relative 'base'
require_relative 'send_webhook'
require 'aws-sdk-s3'

module PdfMage
  module Workers
    # A Sidekiq job that uploads a rendered PDF to Amazon S3.
    # @since 0.1.0
    class UploadFile < PdfMage::Workers::Base
      def perform(pdf_id, callback_url = nil, meta = nil)
        s3 = Aws::S3::Resource.new(
          access_key_id: CONFIG.aws_account_key,
          region: CONFIG.aws_account_region,
          secret_access_key: CONFIG.aws_account_secret
        )
        obj = s3.bucket(CONFIG.aws_account_bucket).object(pdf_id)
        obj.upload_file(pdf_filename(pdf_id))
        pdf_url = obj.presigned_url(:get, expires_in: CONFIG.aws_presigned_url_duration)

        `rm #{pdf_filename(pdf_id)}` if CONFIG.delete_file_on_upload
        PdfMage::Workers::SendWebhook.perform_async(pdf_url, callback_url, meta) if string_present?(callback_url)
      end
    end
  end
end
