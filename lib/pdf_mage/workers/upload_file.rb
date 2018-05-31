require_relative 'base'

module PdfMage
  module Workers
    class UploadFile < PdfMage::Workers::Base
      def perform(pdf_id, callback_url, meta)
        uri = URI(url)
        params = {
          file: file_url,
          meta: deserialize_meta(meta)
        }

        Net::HTTP.post_form(uri, params)
      end
    end
  end
end
