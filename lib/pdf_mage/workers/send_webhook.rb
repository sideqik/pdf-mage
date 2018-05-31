require_relative 'base'
require 'net/http'
require 'uri'

module PdfMage
  module Workers
    class SendWebhook < PdfMage::Workers::Base
      def perform(callback_url, file_url_or_path, meta)
        puts "Sending webhook to [#{callback_url}] for file [#{file_url_or_path}] and meta: #{meta.inspect}"
        params = {
          file: file_url_or_path,
          meta: meta
        }

        data      = params.to_json
        signature = OpenSSL::HMAC.hexdigest('sha1', $config.api_secret, data)

        uri = URI(callback_url)
        req = Net::HTTP::Post.new(callback_url)

        req['content-type']    = 'application/json'
        req['user-agent']      = 'PdfMage/1.0'
        req['X-Pdf-Signature'] = signature

        Net::HTTP.start(uri.hostname, uri.port) do |http|
          puts req.inspect
          http.request(req)
        end
      end
    end
  end
end
