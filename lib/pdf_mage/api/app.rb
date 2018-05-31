require 'sinatra'

module PdfMage
  module Api
    class App < Sinatra::Base
      get '/' do
        'Hello world!'
      end
    end
  end
end
