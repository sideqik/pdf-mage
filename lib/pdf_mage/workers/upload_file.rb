# frozen_string_literal: true

require_relative 'base'
require_relative 'send_webhook'
require 'aws-sdk-s3'

module PdfMage
  module Workers
    # A Sidekiq job that uploads a rendered PDF to Amazon S3.
    # @since 0.1.0
    class UploadFile < PdfMage::Workers::Base
      def perform(pdf_id, callback_url = nil, meta = nil)
        validate_aws_config!

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

      private

      # Checks for the present of all necessary AWS config options.
      def validate_aws_config!
        unless string_exists?(CONFIG.aws_account_key)
          raise ArgumentError, 'You must define aws_account_key in your config file to upload PDFs.'
        end

        unless string_exists?(CONFIG.aws_account_secret)
          raise ArgumentError, 'You must define aws_account_secret in your config file to upload PDFs.'
        end

        unless string_exists?(CONFIG.aws_account_region)
          raise ArgumentError, 'You must define aws_account_region in your config file to upload PDFs.'
        end

        unless string_exists?(CONFIG.aws_account_bucket)
          raise ArgumentError, 'You must define aws_account_bucket in your config file to upload PDFs.'
        end

        if CONFIG.aws_presigned_url_duration.nil?
          raise ArgumentError, 'You must define aws_presigned_url_duration in your config file to upload PDFs.'
        end

        true
      end
    end
  end
end
