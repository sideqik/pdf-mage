# frozen_string_literal: true

require 'pdf_mage/workers/send_webhook'

RSpec.describe PdfMage::Workers::SendWebhook do
  describe '#perform' do
    let(:callback_url) { 'https://example.com/callback' }
    let(:file_path) { 'pdf/example.pdf' }
    let(:meta) { nil }

    subject do
      PdfMage::Workers::SendWebhook.perform_async(file_url, callback_url, meta)
    end

    context 'when file url is present' do
      context 'and the callback url is present' do
        it 'sends the webhook' do
        end
      end

      context 'and the callback url is not present' do
        it 'raises an exception' do
        end
      end
    end

    context 'when file url is not present' do
      context 'and the callback url is present' do
        it 'raises an exception' do
        end
      end

      context 'and the callback url is not present' do
        it 'raises an exception' do
        end
      end
    end

    context 'when meta is present' do
      it 'sends meta with the webhook' do
      end
    end

    context 'when meta is not present' do
      it 'does not send meta with the webhook' do
      end
    end
  end
end
