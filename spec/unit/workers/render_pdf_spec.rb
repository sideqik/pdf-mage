# frozen_string_literal: true

require 'pdf_mage/workers/render_pdf'

RSpec.describe PdfMage::Workers::RenderPdf do
  describe '#perform' do
    let(:callback_url) { 'https://example.com/callback' }
    let(:filename) { nil }
    let(:meta) { nil }
    let(:website_url) { 'https://google.com' }

    subject do
      PdfMage::Workers::RenderPdf.perform_async(website_url, callback_url, filename, meta)
    end

    context 'when given a filename' do
      it 'exports a PDF to the path that matches the filename' do
      end
    end

    context 'when not given a filename' do
      it 'exports a PDF to a path with a generated filename' do
      end
    end

    context 'when an aws_account_key is present' do
      it 'starts an upload file job' do
      end

      context 'and a callback url is present' do
        it 'starts an upload file job' do
        end
      end
    end

    context 'when an aws_account_key is not present' do
      it 'does not start an upload file job' do
      end

      context 'and a callback url is present' do
        it 'starts a send webhook job' do
        end
      end

      context 'and a callback url is not present' do
        it 'does not start a send webhook job' do
        end
      end
    end
  end
end
