require_relative 'base'
require_relative 'send_webhook'
require 'aws-sdk-s3'

module PdfMage
  module Workers
    class UploadFile < PdfMage::Workers::Base
      def perform(pdf_id, callback_url, meta)
        s3 = Aws::S3::Resource.new(
          access_key_id: $config.aws_account_id,
          region: $config.aws_account_region,
          secret_access_key: $config.aws_account_secret
        )
        s3_path = [$config.aws_account_bucket_directory, pdf_id].join('/')
        obj = s3.bucket($config.aws_account_bucket).object(s3_path)

        pdf_filename = "#{$config.pdf_directory}/#{pdf_id}.pdf"
        obj.upload_file(pdf_filename)
        pdf_url = obj.presigned_url(:get, expires_in: $config.aws_presigned_url_duration)

        if callback_url
          PdfMage::Workers::SendWebhook.perform_async(callback_url, pdf_url, meta)
        end
      end
    end
  end
end
