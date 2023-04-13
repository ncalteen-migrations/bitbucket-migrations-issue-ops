# frozen_string_literal: true

require "spec_helper"

describe BbsExporter::ArchiveBuilder, :archive_helpers do
  let(:project_model) do
    bitbucket_server.project_model("MIGR8")
  end

  let(:repository_model) do
    project_model.repository_model("hugo-pages")
  end

  let(:repository) do
    repository_model.repository
  end

  let(:project_model_651) do
    bitbucket_server.project_model("BBS651")
  end

  let(:repository_model_651) do
    project_model_651.repository_model("empty-repo")
  end

  let(:repository_651) do
    repository_model_651.repository
  end

  subject { described_class.new(current_export: current_export) }
  let(:tarball_path) { Tempfile.new("string").path }
  let(:files) { file_list_from_archive(tarball_path) }

  before do
    # Call current_export to initialize database connection
    subject.current_export
  end

  it "makes a tarball with a json file" do
    ExtractedResource.create(model_type: "user", model_url: "https://example.com", data: {"foo" => "bar"}.to_json)
    subject.write_files
    subject.create_tar(tarball_path)

    expect(files).to include("users_000001.json")
  end

  it "adds a schema.json" do
    subject.create_tar(tarball_path)

    expect(files).to include("schema.json")

    dir = Dir.mktmpdir "archive_builder"

    json_data = read_file_from_archive(tarball_path, "schema.json")
    expect(JSON.load(json_data)).to eq({"version" => "1.2.0"})
  end

  it "adds a urls.json" do
    subject.create_tar(tarball_path)

    expect(files).to include("urls.json")
  end

  describe "#clone_repo", :vcr do
    it "can create a clone url" do
      expect(subject.send(:git)).to receive(:clone).with(
        hash_including(
          url: "https://unit-test@example.com/scm/migr8/hugo-pages.git"
        )
      )

      subject.clone_repo(repository)
    end
  end

  describe "#repo_clone_url", :vcr do
    it "adds usernames to URLs" do
      link = subject.send(:repo_clone_url, repository_651)

      expect(link).to eq(
        "https://unit-test@example.com/scm/bbs651/empty-repo.git"
      )
    end

    it "allows a user to be passed explicitly" do
      link = subject.send(:repo_clone_url, repository_651, user: "synthead")

      expect(link).to eq(
        "https://synthead@example.com/scm/bbs651/empty-repo.git"
      )
    end

    it "encodes the user" do
      repository = {"links"=>{"clone"=>[{"href"=>"https://host/repo.git", "name"=>"http"}]}}
      link = subject.send(:repo_clone_url, repository, user: " @#:")

      expect(link).to eq(
        "https://+%40%23%3A@host/repo.git"
      )
    end
  end
end
