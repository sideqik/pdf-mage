require_relative 'base'
require 'typhoeus'

module PdfMage
  module Workers
    class SendWebhook < PdfMage::Workers::Base
      sidekiq_options queue: 'pdfmage'

      def perform(callback_url, file_url_or_path, meta)
        puts "Sending webhook to [#{callback_url}] for file [#{file_url_or_path}] and meta: #{meta.inspect}"
        params = {
          file: file_url_or_path,
          meta: meta
        }

        data      = params.to_json
        signature = OpenSSL::HMAC.hexdigest('sha1', $config.api_secret, data)

        headers = {
          'content-type'    => 'application/json',
          'user-agent'      => 'PdfMage/1.0',
          'X-Pdf-Signature' => signature
        }

        response = Typhoeus.post(callback_url, headers: headers, body: data, ssl_verifypeer: false)
        puts "Received response with status [#{response.code}]: #{response.body}"
      end
    end
  end
end
