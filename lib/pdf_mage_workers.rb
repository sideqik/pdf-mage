# frozen_string_literal: true

MODE = 'worker'.freeze

require 'pdf_mage/init'
require 'pdf_mage/workers/render_pdf'
require 'pdf_mage/workers/send_webhook'
require 'pdf_mage/workers/upload_file'
