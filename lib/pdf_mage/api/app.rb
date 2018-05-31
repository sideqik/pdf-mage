require 'sinatra'
require 'json'

module PdfMage
  module Api
    class App < Sinatra::Base
      set :environment, :production

      before do
        content_type :json
        error(401, 'Unauthorized') unless params[:token].strip == $config.api_secret
      end

      error do
        e = env['sinatra.error']
        error(500, e.message)
      end

      get '/api/ping' do
        'pong'
      end

      post '/api/render' do
        url          = required_param(:url)
        callback_url = required_param(:callback_url)
        meta         = params[:meta] || ""

        job_id = PdfMage::Workers::RenderPdf.perform_async(url, callback_url, meta)
        {result: 'ok', job_id: job_id}.to_json
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
