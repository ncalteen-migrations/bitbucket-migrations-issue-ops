# frozen_string_literal: true

require "spec_helper"

describe BbsExporter::PullRequestExporter, :vcr do
  let(:project_model) do
    bitbucket_server.project_model("MIGR8")
  end

  let(:repository_model) do
    project_model.repository_model("hugo-pages")
  end

  let(:pull_request_model) do
    repository_model.pull_request_model(1)
  end

  let(:repository) do
    repository_model.repository
  end

  let(:pull_request) do
    pull_request_model.pull_request
  end

  let(:bbs_model) do
    {
      repository:   repository,
      pull_request: pull_request,
      description:  pull_request["description"]
    }
  end

  let(:repository_exporter) do
    BbsExporter::RepositoryExporter.new(
      repository_model: repository_model,
      current_export:   current_export
    )
  end

  let(:pull_request_exporter) do
    BbsExporter::PullRequestExporter.new(
      pull_request_model:  pull_request_model,
      repository_exporter: repository_exporter
    )
  end

  describe "#model" do
    it "aliases to the pull_request" do
      expect(pull_request_exporter.model).to eq(
        pull_request_exporter.pull_request
      )
    end
  end

  describe "#repository" do
    it "returns the repository from the repository_exporter" do
      expect(pull_request_exporter.repository).to eq(repository)
    end
  end

  describe "#created_date" do
    it "returns the timestamp of when the pull_request was created" do
      expect(pull_request_exporter.created_date).to eq(1495567609873)
    end
  end

  describe "#grouped_diff_comment_activities" do
    context "from the activities in a pull request" do
      subject(:grouped_activities) do
        pull_request_exporter.grouped_diff_comment_activities
      end

      it "should return an array" do
        expect(grouped_activities).to be_an_instance_of(Array)
      end

      it "should group commit IDs and first activites correctly" do
        expect(grouped_activities.count).to eq(2)

        commit_id, activity = grouped_activities.first
        expect(commit_id).to eq("98bb7937d0bf95f194d52ac05352f3546b6240e8")
        expect(activity["id"]).to eq(75)

        commit_id, activity = grouped_activities.last
        expect(commit_id).to eq("98bb7937d0bf95f194d52ac05352f3546b6240e8")
        expect(activity["id"]).to eq(6)
      end
    end
  end

  describe "#export" do
    subject(:_export) { pull_request_exporter.export }

    it { is_expected.to be_truthy }

    it "should serialize the model" do
      expect(pull_request_exporter).to receive(:serialize).with(
        "pull_request", bbs_model, nil
      )
      expect(pull_request_exporter).to receive(:serialize).with(
        "user", pull_request_exporter.pull_request["author"]["user"], nil
      )

      pull_request_exporter.export
    end

    it "should export all of the pull request comments" do
      expect(pull_request_exporter).to receive(
        :export_pull_request_comments
      ).once

      pull_request_exporter.export
    end

    it "should export pull request reviews" do
      expect(pull_request_exporter).to receive(
        :export_pull_request_reviews
      ).once

      pull_request_exporter.export
    end

    it "should export pull request review comments" do
      expect(pull_request_exporter).to receive(
        :export_pull_request_review_comments
      ).once

      pull_request_exporter.export
    end

    it "should export issue events" do
      expect(pull_request_exporter).to receive(
        :export_issue_events
      ).once

      pull_request_exporter.export
    end

    it "should export pull request file comments" do
      expect(pull_request_exporter).to receive(
        :export_pull_request_file_comments
      ).once

      pull_request_exporter.export
    end

    context "with an invalid Comment" do
      let(:comment) { pull_request_exporter.comment_activities.first }

      before { comment["comment"].delete("author") }

      it { is_expected.to be_truthy }
    end

    context "with an invalid Review Comment" do
      let(:review_comment) { pull_request_exporter.diff_comment_activities.first }

      before { review_comment.delete("user") }

      it { is_expected.to be_truthy }
    end

    context "with an invalid Review" do
      let(:review) { pull_request_exporter.review_activities.first }

      before { review.delete("user") }

      it { is_expected.to be_truthy }
    end

    # This test was recorded against our https://test-bbs-o.githubapp.com instance
    # and the PR https://test-bbs-o.githubapp.com/projects/IM/repos/test-commit-id-blank-review/pull-requests/1/overview
    # where the review activity is not able to be placed on a commit due to timeshift (the commit was timeshifted so that review timestamp is before the commit timestamp)
    context "with a review activity that can't be placed on a commit" do
      let(:project_model) do
        bitbucket_server.project_model("IM")
      end

      let(:repository_model) do
        project_model.repository_model("test-commit-id-blank-review")
      end

      let(:pull_request_model) do
        repository_model.pull_request_model(1)
      end

      let(:repository) do
        repository_model.repository
      end

      let(:pull_request) do
        pull_request_model.pull_request
      end

      it "should export pull request reviews" do
        expect(pull_request_exporter).to receive(
          :export_pull_request_reviews
        ).once

        pull_request_exporter.export
      end
    end

    context "when a pull request has no commits" do
      before(:each) do
        allow(pull_request_model).to receive(:commits).and_return([])
      end

      it "should not serialize data" do
        expect(pull_request_exporter).to_not receive(:serialize)

        pull_request_exporter.export
      end

      it "should write a warning to the export log" do
        expect(pull_request_exporter).to receive(:log_with_url).with(
          severity:   :warn,
          message:    "was skipped because the PR has no diff",
          model:      bbs_model,
          model_name: "pull_request",
          console:    true
        )

        pull_request_exporter.export
      end

      it "should not export attachments" do
        expect(pull_request_exporter.attachment_exporter).to_not receive(
          :export
        )

        pull_request_exporter.export
      end

      it "should not export pull request comments" do
        expect(pull_request_exporter).to_not receive(
          :export_pull_request_comments
        )

        pull_request_exporter.export
      end

      it "should not export pull request review groups" do
        expect(pull_request_exporter).to_not receive(
          :export_pull_request_review_groups
        )

        pull_request_exporter.export
      end

      it "should not export pull request review comments" do
        expect(pull_request_exporter).to_not receive(
          :export_pull_request_review_comments
        )

        pull_request_exporter.export
      end

      it "should not export pull request reviews" do
        expect(pull_request_exporter).to_not receive(
          :export_pull_request_reviews
        )

        pull_request_exporter.export
      end

      it "should not export issue events" do
        expect(pull_request_exporter).to_not receive(:export_issue_events)

        pull_request_exporter.export
      end
    end

    context "when the description includes an attachment" do
      subject(:bbs_model_with_rewritten_url) do
        bbs_model.merge(
          description: "[![octocat.png](https://example.com/projects/MIGR8/" \
            "repos/hugo-pages/attachments/955b9a8607/octocat.png)](" \
            "https://example.com/projects/MIGR8/repos/hugo-pages/attachments/" \
            "955b9a8607/octocat.png 'octocat')"
        )
      end

      let(:pull_request_model) { repository_model.pull_request_model(9) }

      it "rewrites the attachment URLs" do
        allow(pull_request_exporter).to receive(:serialize).with(
          "user", anything, nil
        )

        expect(pull_request_exporter).to receive(:serialize).with(
          "pull_request", bbs_model_with_rewritten_url, nil
        )

        pull_request_exporter.export
      end
    end
  end

  describe "#timestamped_commit_ids" do
    it "should use the author timestamp" do
      commits = [
        {
          "id"                 => "abcde",
          "authorTimestamp"    => 1000,
          "committerTimestamp" => 2000
        }
      ]

      allow(pull_request_model).to receive(:commits).and_return(commits)

      expected = { 1000 => "abcde" }
      expect(pull_request_exporter.timestamped_commit_ids).to eq(expected)
    end
  end

  describe "#commit_id_for_timestamp" do
    let(:timestamp) { 1555975351001 }

    it "returns the commit id previous to the provided timestamp" do
      expect(pull_request_exporter.commit_id_for_timestamp(timestamp))
        .to eq("b973fdcba0f85bf8556630d02ad9d6bef966a61e")
    end

    context "when no commit matches" do
      let(:timestamp) { 1495567557999 }

      it "returns REVIEW_BLANK_COMMIT_SHA" do
        expect(pull_request_exporter.commit_id_for_timestamp(timestamp)).to eq(described_class::REVIEW_BLANK_COMMIT_SHA)
      end
    end
  end

  describe "#attachment_exporter" do
    subject(:attachment_exporter) do
      pull_request_exporter.attachment_exporter
    end

    it "sets current_export to the correct value" do
      expect(attachment_exporter.current_export).to eq(
        pull_request_exporter.current_export
      )
    end

    it "sets repository_model to the correct value" do
      expect(attachment_exporter.repository_model).to eq(
        pull_request_exporter.repository_model
      )
    end

    it "sets parent_type to the correct value" do
      expect(attachment_exporter.parent_type).to eq(
        "pull_request"
      )
    end

    it "sets parent_model to the correct value" do
      expect(attachment_exporter.parent_model).to eq(
        pull_request_exporter.bbs_model
      )
    end

    it "sets attachment_exporter to the correct value" do
      expect(attachment_exporter.user).to eq(
        pull_request_exporter.author
      )
    end

    it "sets body to the correct value" do
      expect(attachment_exporter.body).to eq(
        pull_request_exporter.description
      )
    end

    it "sets created_date to the correct value" do
      expect(attachment_exporter.created_date).to eq(
        pull_request_exporter.created_date
      )
    end
  end

  describe "#comment_body_for_file_comment", :pull_request_helpers do
    let(:pull_request_model) do
      repository_model.pull_request_model(6)
    end

    let(:activities) do
      pull_request_model.activities
    end

    context "for a given activity" do
      subject(:activity) do
        comment_activity_start_with(activities, "File comment.")
      end

      it "includes the original comment body" do
        body = pull_request_exporter.comment_body_for_review_file_comment(
          activity
        )
        original_body = activity["comment"]["text"]
        expect(body.end_with?(original_body)).to eq(true)
      end
    end
  end
end
