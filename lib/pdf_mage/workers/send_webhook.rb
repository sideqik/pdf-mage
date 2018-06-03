require_relative 'base'
require 'typhoeus'

module PdfMage
  module Workers
    class SendWebhook < PdfMage::Workers::Base
      def perform(file_url_or_path, callback_url, meta=nil)
        $logger.info "Sending webhook to [#{callback_url}] for file [#{file_url_or_path}] and meta: #{meta.inspect}"
        params = {
          file: file_url_or_path,
          meta: meta
        }

        data    = params.to_json
        headers = {
          'content-type'    => 'application/json',
          'user-agent'      => 'PdfMage/1.0',
        }

        if $config.api_secret
          headers['X-Pdf-Signature'] = OpenSSL::HMAC.hexdigest('sha1', $config.api_secret, data)
        end

        response = Typhoeus.post(callback_url, headers: headers, body: data, ssl_verifypeer: !$env.development)
        $logger.info "Received response with status [#{response.code}]: #{response.body}"
      end
    end
  end
end
