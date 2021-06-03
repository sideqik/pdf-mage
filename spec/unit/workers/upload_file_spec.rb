# coding: utf-8
# frozen_string_literal: true

require 'pdf_mage/workers/upload_file'

RSpec.describe PdfMage::Workers:: UploadFile do
  describe '#perform' do
    let(:callback_url) { nil }
    let(:meta) { nil }
    let(:pdf_id) { 'example' }

    subject do
      PdfMage::Workers::UploadFile.perform_async(pdf_id, callback_url, meta)
    end

    it 'creates the bucket on S3' do
    end

    context 'when delete_file_on_upload is enabled' do
      before do
        allow(CONFIG).to receive(:delete_file_on_upload).and_return(true)
      end

      it 'deletes the file' do
      end
    end

    context 'when delete_file_on_upload is disabled' do
      before do
        allow(CONFIG).to receive(:delete_file_on_upload).and_return(false)
      end

      it 'leaves the file in place' do
      end
    end
  end
end
