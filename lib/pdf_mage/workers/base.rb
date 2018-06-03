require 'fileutils'
require 'sidekiq'

module PdfMage
  module Workers
    class Base
      include Sidekiq::Worker
      sidekiq_options queue: 'pdfmage'

      def ensure_directory_exists_for_pdf(filename)
        directory_path = filename.split('/').slice(0..-2).join('/')
        FileUtils.mkdir_p(directory_path)
      end

      def pdf_filename(pdf_id)
        return @filename if @filename

        filename = "#{$config.pdf_directory}/#{pdf_id}"
        filename += '.pdf' if !pdf_id.end_with?('.pdf')

        @filename = filename
      end
    end
  end
end
