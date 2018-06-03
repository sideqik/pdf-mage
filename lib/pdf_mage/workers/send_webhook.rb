require_relative 'base'
require 'typhoeus'

module PdfMage
  module Workers
    # A Sidekiq job that sends a webhook after a PDF has been rendered or uploaded.
    # @since 0.1.0
    class SendWebhook < PdfMage::Workers::Base
      def perform(file_url_or_path, callback_url, meta = nil)
        LOGGER.info "Sending webhook to [#{callback_url}] for file [#{file_url_or_path}] and meta: #{meta.inspect}"
        params = {
          file: file_url_or_path,
          meta: meta
        }

        data = params.to_json
        headers = {
          'content-type' => 'application/json',
          'user-agent' => 'PdfMage/1.0'
        }

        headers['X-Pdf-Signature'] = OpenSSL::HMAC.hexdigest('sha1', CONFIG.api_secret, data) if CONFIG.api_secret

        response = Typhoeus.post(callback_url, headers: headers, body: data, ssl_verifypeer: !CONFIG.env.development)
        LOGGER.info "Received response with status [#{response.code}]: #{response.body}"
      end
    end
  end
end
