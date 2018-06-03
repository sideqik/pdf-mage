# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'pdf_mage/workers/render_pdf'

module PdfMage
  module Api
    class App < Sinatra::Base
      set :environment, :production

      before do
        content_type :json
      end

      error do
        e = env['sinatra.error']
        error(500, e.message)
      end

      get '/status' do
        { result: 'ok' }.to_json
      end

      post '/render' do
        authorize()
        url          = required_param(:url)
        callback_url = required_param(:callback_url)
        filename     = params[:filename]
        meta         = params[:meta] || ""

        job_id = PdfMage::Workers::RenderPdf.perform_async(url, callback_url, filename, meta)
        { result: 'ok', job_id: job_id }.to_json
      end

      def authorize
        if $config.api_secret
          error(401, 'Unauthorized') unless params[:token] && params[:token].strip == $config.api_secret
        end
      end

      def error(code, message)
        halt code, {result: 'error', message: message}.to_json
      end

      def required_param(key)
        value = params[key]
        error(422, "Required parameter '#{key}' is missing") unless value && value.length > 0
        value
      end
    end
  end
end
