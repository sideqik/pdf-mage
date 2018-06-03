require 'fileutils'
require 'sidekiq'

module PdfMage
  module Workers
    # Base worker class that configures Sidekiq options and all workers extend.
    # @since 0.1.0
    class Base
      include Sidekiq::Worker
      sidekiq_options queue: 'pdfmage'

      def ensure_directory_exists_for_pdf(filename)
        directory_path = filename.split('/').slice(0..-2).join('/')
        FileUtils.mkdir_p(directory_path)
      end

      def string_exists?(string)
        string && !string.empty?
      end

      def pdf_filename(pdf_id)
        return @filename if @filename

        filename = "#{CONFIG.pdf_directory}/#{pdf_id}"
        filename += '.pdf' unless pdf_id.end_with?('.pdf')

        @filename = filename
      end
    end
  end
end
