# frozen_string_literal: true

require 'pdf_mage/api/app'

RSpec.describe PdfMage::Api::App do
  describe '/render' do
    it 'starts a render job' do
      # expect(PdfMage::Workers::RenderPdf).to receive(:perform_async)
    end
  end

  describe '/status' do
    it 'returns the status' do
      # TODO: add a spec
    end
  end
end
