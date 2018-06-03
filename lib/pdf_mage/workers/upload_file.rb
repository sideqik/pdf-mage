require_relative 'base'
require_relative 'send_webhook'
require 'aws-sdk-s3'

module PdfMage
  module Workers
    class UploadFile < PdfMage::Workers::Base
      def perform(pdf_id, callback_url=nil, meta=nil)
        s3 = Aws::S3::Resource.new(
          access_key_id: $config.aws_account_id,
          region: $config.aws_account_region,
          secret_access_key: $config.aws_account_secret
        )
        obj = s3.bucket($config.aws_account_bucket).object(pdf_id)
        obj.upload_file(pdf_filename(pdf_id))
        pdf_url = obj.presigned_url(:get, expires_in: $config.aws_presigned_url_duration)

        if $config.delete_file_on_upload
          %x[rm #{pdf_filename(pdf_id)}]
        end

        if callback_url && !callback_url.empty?
          PdfMage::Workers::SendWebhook.perform_async(pdf_url, callback_url, meta)
        end
      end
    end
  end
end
