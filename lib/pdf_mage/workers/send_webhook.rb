require_relative 'base'
require 'net/http'
require 'uri'

module PdfMage
  module Workers
    class SendWebhook < PdfMage::Workers::Base
      def perform(callback_url, file_url_or_path, meta)
        uri = URI(url)
        params = {
          file: file_url_or_path,
          meta: deserialize_meta(meta)
        }

        Net::HTTP.post_form(uri, params)
      end
    end
  end
end
