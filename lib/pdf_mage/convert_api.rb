require 'base64'
require 'typhoeus'
require 'json'

module ConvertApi
  CONVERT_PATTERN = 'https://v2.convertapi.com/convert/:from/to/:to?Secret=:secret&File=:file_id&StoreFile=true'
  UPLOAD_URL  = 'https://v2.convertapi.com/upload'

  # Accepts a file path and returns a ConvertAPI file id
  def self.upload_file(filepath)
    file = File.open(filepath)
    filename = file.path.split('/').last

    response = Typhoeus::Request.new(
      UPLOAD_URL,
      method: :post,
      params: {
        'Secret' => 'jjlOQjqI7Nl2nY8d'#CONFIG['convertapi_secret']
      },
      headers: {
        'Content-Disposition' => "inline; filename=\"#{filename}\""
      },
      body: { file: file }
    ).run

    parsed_response = JSON.parse(response.body)
    parsed_response['FileId']
  end

  # Accepts a ConvertAPI file id, a source format, and a target format and
  # returns the URL of the converted file
  def self.convert(file_id, from:, to:)
    url = CONVERT_PATTERN.
            gsub(':from', from).
            gsub(':to', to).
            gsub(':secret', 'jjlOQjqI7Nl2nY8d').
            #gsub(':secret', CONFIG['convertapi_secret']).
            gsub(':file_id', file_id)
    response = Typhoeus.post(url)

    if response.code > 299
      raise RequestError, "received response code #{response.code}"
    end

    parsed_response = JSON.parse(response.body)
    parsed_response['Files'].map { |f| f['Url'] } # will always be one file for pdf -> pptx
  end

  class RequestError < StandardError; end
end
