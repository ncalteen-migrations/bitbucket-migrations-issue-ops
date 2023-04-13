# frozen_string_literal: true

require "spec_helper"

describe BbsExporter::AttachmentExporter do
  let(:project_model) do
    bitbucket_server.project_model("MIGR8")
  end

  let(:repository_model) do
    project_model.repository_model("hugo-pages")
  end

  let(:pull_request_model) do
    repository_model.pull_request_model(9)
  end

  let(:pull_request) do
    pull_request_model.pull_request
  end

  let(:repository) do
    repository_model.repository
  end

  let(:pull_request_serializer_params) do
    {
      pull_request: pull_request,
      repository:   repository
    }
  end

  let(:expected_url) do
    "https://example.com/projects/MIGR8/repos/hugo-pages/attachments/" \
    "955b9a8607/octocat.png"
  end

  let(:expected_asset_url) do
    "tarball://root/attachments/d185c08aecb7ed9bc007403df3d001a5.png"
  end

  let(:attachment_exporter) do
    described_class.new(
      current_export:   current_export,
      repository_model: repository_model,
      parent_type:      "pull_request",
      parent_model:     pull_request_serializer_params,
      user:             pull_request["author"]["user"],
      body:             pull_request["description"],
      created_date:     pull_request["createdDate"]
    )
  end

  before(:each) do
    allow(repository_model).to receive(:attachment_content_type).and_return(
      "image/png"
    )
    allow(repository_model).to receive(:attachment).and_return(StringIO.new)
  end

  describe "#rewritten_body", :vcr do
    it "updates markdown links" do
      expect(attachment_exporter.rewritten_body).to eq(
        "[![octocat.png](#{expected_url})](#{expected_url} 'octocat')"
      )
    end
  end

  describe "#export", :vcr do
    context "with supported attachment" do
      it "saves attachments to the archive" do
        attachment_exporter.attachments.each do |attachment|
          expect(attachment).to receive(:archive!)
        end

        attachment_exporter.export
      end

      it "serializes attachments" do
        expected_model = {
          parent_type:         "pull_request",
          parent_model:        pull_request_serializer_params,
          user:                pull_request["author"]["user"],
          created_date:        pull_request["createdDate"],
          url:                 expected_url,
          asset_url:           expected_asset_url,
          asset_name:          "octocat.png",
          asset_content_type:  "image/png"
        }

        expect(attachment_exporter).to receive(:serialize).with(
          "attachment", expected_model, nil
        ).twice

        attachment_exporter.export
      end
    end

    context "with unsupported attachment" do
      let(:pull_request_model) do
        repository_model.pull_request_model(14)
      end

      it "does not serialize the attachment" do
        allow(repository_model).to receive(:attachment_content_type).and_return(
          "image/svg+xml"
        )

        attachment_exporter.attachments.each do |attachment|
          expect(attachment_exporter).to_not receive(:serialize)
        end

        attachment_exporter.export
      end
    end
  end
end
