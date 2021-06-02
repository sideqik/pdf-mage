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

    context 'when aws_account_key is missing' do
      before do
        allow(CONFIG).to receive(:aws_account_key).and_return(nil)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when aws_account_secret is missing' do
      before do
        allow(CONFIG).to receive(:aws_account_secret).and_return(nil)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when aws_account_region is missing' do
      before do
        allow(CONFIG).to receive(:aws_account_region).and_return(nil)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when aws_account_bucket is missing' do
      before do
        allow(CONFIG).to receive(:aws_account_bucket).and_return(nil)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
