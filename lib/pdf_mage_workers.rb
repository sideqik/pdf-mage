# frozen_string_literal: true

MODE = 'worker'

require 'pdf_mage/init'
require 'pdf_mage/workers/render_pdf'
require 'pdf_mage/workers/render_pptx'
require 'pdf_mage/workers/send_webhook'
require 'pdf_mage/workers/upload_file'
