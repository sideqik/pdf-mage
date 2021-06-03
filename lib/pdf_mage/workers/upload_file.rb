# frozen_string_literal: true

require_relative 'base'
require_relative 'send_webhook'
require_relative '../convert_api'
require 'aws-sdk-s3'
require 'open-uri'

module PdfMage
  module Workers
    class UploadFile < PdfMage::Workers::Base
      def perform(filename, callback_url = nil, meta = nil)
        LOGGER.info "Uploading file [#{filename}] with callback [#{callback_url}] and meta: #{meta.inspect}}"

        s3 = Aws::S3::Resource.new(
          access_key_id: CONFIG.aws_account_key,
          region: CONFIG.aws_account_region,
          secret_access_key: CONFIG.aws_account_secret
        )

        s3_key = filename
        obj = s3.bucket(CONFIG.aws_account_bucket).object(filename)
        file_extension = filename.split('.')[-1]
        content_type = case file_extension
                       when 'pdf'
                         'application/pdf'
                       when 'pptx'
                         'application/vnd.openxmlformats-officedocument.presentationml.presentation'
                       end
        download_filename = "Sideqik Export.#{file_extension}"

        File.open(filename) do |file|
          obj.put(
            content_type: content_type,
            content_disposition: "attachment; filename=\"#{download_filename}\"",
            body: file
          )
        end

        if CONFIG.delete_file_on_upload
          `rm #{filename}`
        end

        if string_exists?(callback_url)
          LOGGER.info("Sending webhook to callback...")
          PdfMage::Workers::SendWebhook.perform_async(s3_key, callback_url, meta)
        end
      end
    end
  end
end
