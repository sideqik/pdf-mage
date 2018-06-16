# frozen_string_literal: true

require 'fileutils'
require 'pdf_mage/workers/base'
require 'uri'

RSpec.describe PdfMage::Workers::Base do
  subject { PdfMage::Workers::Base.new }

  describe '#secretize_url' do
    let(:url) { nil }
    subject { super().secretize_url(url) }

    context 'when an API secret is present' do
      before do
        allow(CONFIG).to receive(:api_secret).and_return('SECRET')
      end

      let(:url) { 'https://sideqik.com/influencers?ids=1,2,3' }
      it 'adds the secret to the url' do
        query_params = URI.decode_www_form(URI(subject).query).to_h
        expect(query_params).to include('secret' => 'SECRET')
      end

      it 'leaves the resource intact' do
        expect(subject).to start_with('https://sideqik.com/influencers')
      end

      it 'leaves params intact' do
        query_params = URI.decode_www_form(URI(subject).query).to_h
        expect(query_params).to include('ids' => '1,2,3')
      end
    end

    context 'when API secret is not present' do
      let(:url) { 'https://sideqik.com/influencers?ids=1,2,3' }
      it 'returns the URL without a secret added' do
        expect(subject).to eq(url)
      end
    end

    context 'when url is not present' do
      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when url is not a valid URL' do
      let(:url) { 'sideqik.com' }
      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#ensure_directory_exists_for_pdf' do
    let(:filename) { nil }
    subject { super().ensure_directory_exists_for_pdf(filename) }

    context 'when filename contains a subdirectory' do
      let(:filename) { 'wacky/wizards/red.pdf' }
      it 'calls FileUtils to make the directory' do
        expect(FileUtils).to receive(:mkdir_p).with('wacky/wizards')
        subject
      end
    end

    context 'when filename does not contain a subdirectory' do
      let(:filename) { 'mage.pdf' }
      it 'calls FileUtils to make the directory' do
        expect(FileUtils).to_not receive(:mkdir_p)
        subject
      end
    end

    context 'when filename is not present' do
      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#pdf_filename' do
    let(:pdf_id) { 'cool' }
    subject { super().pdf_filename(pdf_id) }

    context 'when cached filename exists' do
      subject do
        base_job = PdfMage::Workers::Base.new
        base_job.instance_variable_set(:@filename, 'wacky')
        base_job.pdf_filename(pdf_id)
      end

      it 'returns the cached filename' do
        expect(subject).to eq('wacky')
      end
    end

    context 'when pdf_id does not end with .pdf' do
      it 'appends .pdf to it' do
        expect(subject).to eq('pdfs/cool.pdf')
      end
    end

    context 'when pdf_id ends with .pdf' do
      let(:pdf_id) { 'cool.pdf' }
      it 'does not append an extra .pdf' do
        expect(subject).to eq('pdfs/cool.pdf')
      end
    end

    context 'when pdf_id is not present' do
      let(:pdf_id) { nil }
      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when pdf_directory is not present' do
      before do
        allow(CONFIG).to receive(:pdf_directory).and_return('')
      end

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#string_exists?' do
    let(:string) { nil }
    subject { super().string_exists?(string) }

    context 'when string is nil' do
      let(:string) { nil }
      it 'returns false' do
        expect(subject).to be(false)
      end
    end

    context 'when string is empty' do
      let(:string) { '' }
      it 'returns false' do
        expect(subject).to be(false)
      end
    end

    context 'when string is present' do
      let(:string) { 'I am happy!' }
      it 'returns true' do
        expect(subject).to be(true)
      end
    end
  end

  describe '#strip_string' do
    let(:string) { nil }
    subject { super().strip_string(string) }

    context 'when the string is present' do
      let(:string) { 'I am super happy! 😀' }

      it 'returns a string with only ASCII characters' do
        expect(subject).to eq('I am super happy! ')
      end
    end

    context 'when the string is nil' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
