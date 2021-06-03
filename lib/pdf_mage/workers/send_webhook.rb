# frozen_string_literal: true

require_relative 'base'
require 'typhoeus'

module PdfMage
  module Workers
    # A Sidekiq job that sends a webhook after a PDF has been rendered or uploaded.
    # @since 0.1.0
    class SendWebhook < PdfMage::Workers::Base
      def perform(s3_key, callback_url, meta = nil)
        LOGGER.info "Sending webhook to [#{callback_url}] for file [#{s3_key}] and meta: #{meta.inspect}"
        params = {
          s3_bucket: CONFIG.aws_account_bucket,
          s3_key: s3_key,
          meta: meta
        }

        data = params.to_json
        headers = {
          'content-type' => 'application/json',
          'user-agent' => 'PdfMage/1.0'
        }

        headers['X-Export-Signature'] = OpenSSL::HMAC.hexdigest('sha256', CONFIG.api_secret, data) if CONFIG.api_secret

        response = Typhoeus.post(callback_url, headers: headers, body: data, ssl_verifypeer: !CONFIG.env.development)
        LOGGER.info "Received response with status [#{response.code}]: #{response.body}"
      end
    end
  end
end
