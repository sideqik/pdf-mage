require 'json'
require 'sidekiq'

module PdfMage
  module Workers
    class Base
      include Sidekiq::Worker

      def deserialize_meta(json_hash)
        JSON.fast_generate(json_hash) if json_hash
      end

      def serialize_meta(ruby_hash)
        JSON.parse(ruby_hash) if ruby_hash
      end
    end
  end
end
