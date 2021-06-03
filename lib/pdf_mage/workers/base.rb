# frozen_string_literal: true

require 'fileutils'
require 'sidekiq'
require 'uri'

module PdfMage
  module Workers
    # Base worker class that configures Sidekiq options and all workers extend.
    # @since 0.1.0
    class Base
      include Sidekiq::Worker
      sidekiq_options queue: 'pdfmage'

      # Options for the strip string method, for use with the String#encode method.
      # @private
      STRIP_STRING_OPTIONS = {
        invalid: :replace,
        undef: :replace,
        replace: '',
        universal_newline: true
      }.freeze

      # Creates directories in the filesystem for the given filename, so that writing a file to that location succeeds.
      #
      # @param [String] filename - string that represents the path the PDF will be created at
      # @return [NilClass]
      #
      # @raise [ArgumentError] if filename is nil or an empty string
      def ensure_directory_exists_for_pdf(filename)
        unless string_exists?(filename)
          raise ArgumentError, 'filename must be a string that includes at least 1 ASCII character.'
        end

        directory_path = filename.split('/').slice(0..-2).join('/')
        FileUtils.mkdir_p(directory_path) if string_exists?(directory_path)
        nil
      end

      # Generates a filename for a unique PDF identifier using the pdf directory specified in the config and the given
      # pdf id.
      #
      # @param [String] export_id - Export identifier to make filename from
      # @return [String] filename to store PDF at
      #
      # @raise [ArgumentError] if export_id is nil or an empty string
      # @raise [ArgumentError] if CONFIG.export_directory is nil or an empty string
      def pdf_filename(export_id)
        unless string_exists?(export_id)
          raise ArgumentError, 'export_id must be a string that includes at least 1 ASCII character.'
        end

        unless string_exists?(CONFIG.export_directory)
          raise ArgumentError, '
            The export_directory in your config.yml must be a string that includes at least 1 ASCII character.
          '
        end

        filename = "#{CONFIG.export_directory}/#{export_id}"
        filename += '.pdf' unless export_id.end_with?('.pdf')

        filename
      end

      # Generates a filename for a unique PPTX identifier using the exports directory specified in the config and the given
      # export id.
      #
      # @param [String] export_id - Export identifier to make filename from
      # @return [String] filename to store PPTX at
      #
      # @raise [ArgumentError] if export_id is nil or an empty string
      # @raise [ArgumentError] if CONFIG.export_directory is nil or an empty string
      def pptx_filename(export_id)
        unless string_exists?(export_id)
          raise ArgumentError, 'export_id must be a string that includes at least 1 ASCII character.'
        end

        unless string_exists?(CONFIG.export_directory)
          raise ArgumentError, '
            The export_directory in your config.yml must be a string that includes at least 1 ASCII character.
          '
        end

        filename = "#{CONFIG.export_directory}/#{export_id}"
        filename += '.pptx' unless export_id.end_with?('.pptx')

        filename
      end

      # Adds the API secret to a URL.
      #
      # @param [String] url - URL to add the API secret from the config to
      # @return [String] url with secret
      #
      # @raise [ArgumentError] if url is nil or an empty string
      def secretize_url(url)
        unless string_exists?(url) && (uri = URI(url)) && uri.scheme&.match(/^https?$/)
          raise ArgumentError, 'url must be a valid url using the http/s protocol.'
        end

        if CONFIG.api_secret
          new_query_params = URI.decode_www_form(uri.query.to_s) << ['secret', CONFIG.api_secret]
          uri.query = URI.encode_www_form(new_query_params)
          uri.to_s
        else
          url
        end
      end

      # Checks if the given string is not nil and is not empty, like ActiveSupport's String#present?
      #
      # @param [String] string - string to strip non-ASCII characters from
      # @return [TrueClass, FalseClass] boolean of if the string is present or not
      def string_exists?(string)
        !string.nil? && !string.empty?
      end

      # Removes all non-ASCII characters from a string.
      #
      # @param [String] string - string to strip non-ASCII characters from
      # @return [String, NilClass] string with non-ASCII characters removed or nil if given nil
      def strip_string(string)
        string&.encode(Encoding.find('ASCII'), STRIP_STRING_OPTIONS)
      end
    end
  end
end
