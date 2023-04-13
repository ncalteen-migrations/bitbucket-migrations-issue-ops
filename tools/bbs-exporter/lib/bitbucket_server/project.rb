# frozen_string_literal: true

class BitbucketServer
  class Project < Model
    api :core

    attr_reader :key

    def initialize(connection:, key:)
      @connection = connection
      @key = key
      @path = ["projects", key]
    end

    # Create a BitbucketServer::Repository model.
    #
    # @param [String] repository_slug the repository_slug of the repository
    # @return [BitbucketServer::Repository]
    def repository_model(repository_slug)
      Repository.new(
        connection:    @connection,
        project_model: self,
        slug:          repository_slug
      )
    end

    # Get the project.
    #
    # @return [Hash]
    def project
      get
    end

    # Get members.
    #
    # @return [Array<Hash>]
    def members
      get("permissions", "users", pagination: :standard)
    end

    # Get group access.
    #
    # @return [Array<Hash>]
    def group_access
      get("permissions", "groups", pagination: :standard)
    end

    def user_project?
      key.start_with?("~")
    end
  end
end
