# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exports::Create do
  describe '#call' do
    subject(:create_export) { described_class.new(export:, start_at:, end_at:).call }

    let(:user) { create(:user) }
    let(:start_at) { DateTime.new(2021, 1, 1).to_s }
    let(:end_at) { DateTime.new(2021, 1, 2).to_s }
    let(:export_name) { "#{start_at.to_date}_#{end_at.to_date}" }
    let(:export) { create(:export, user:, name: export_name, status: :created) }
    let(:export_content) { ExportSerializer.new(points, user.email).call }
    let!(:points) { create_list(:point, 10, user:, timestamp: start_at.to_datetime.to_i) }

    it 'writes the data to a file' do
      create_export

      file_path = Rails.root.join('public', 'exports', "#{export_name}.json")

      expect(File.read(file_path)).to eq(export_content)
    end

    it 'updates the export url' do
      create_export

      expect(export.reload.url).to eq("exports/#{export.name}.json")
    end

    it 'updates the export status to completed' do
      create_export

      expect(export.reload.completed?).to be_truthy
    end

    it 'creates a notification' do
      expect { create_export }.to change { Notification.count }.by(1)
    end

    context 'when an error occurs' do
      before do
        allow(File).to receive(:open).and_raise(StandardError)
      end

      it 'updates the export status to failed' do
        create_export

        expect(export.reload.failed?).to be_truthy
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with('====Export failed to create: StandardError')

        create_export
      end

      it 'creates a notification' do
        expect { create_export }.to change { Notification.count }.by(1)
      end
    end
  end
end
