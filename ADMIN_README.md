# Migration issue ops repository setup guide

> **Note:** This README file is for administrators who will be configuring and
> maintaining this repository. For end-user instructions, refer to the main
> [README.md](./README.md).

When using this codebase to migrate repositories in your organization, there are
a few things that will need to be created/modified.

## Issue labels

Create the following issue labels. See
[Creating a label](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels#creating-a-label)
for instructions.

1. `bitbucket-server`
2. `bitbucket-cloud`
3. `migration`

### Secrets

Create the following secrets in the repository that is hosting this utility. See
[Creating encrypted secrets for a repository](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)
for instructions.

| Secret                     | Description                                                                          |
| -------------------------- | ------------------------------------------------------------------------------------ |
| `GHEC_ADMIN_TOKEN`         | Personal access token with permissions in the target GitHub Enterprise organization. |
| `GHEC_TARGET_ORGANIZATION` | The name of the target organization to migrate into.                                 |
| `BBS_ADMIN_TOKEN`          | Bitbucket Server HTTP access token with project and repository admin permissions.    |
| `BBS_ADMIN_USERNAME`       | Username of the Bitbucket Server admin the token was generated from.                 |
| `BBS_URL`                  | Bitbucket Server URL (e.g. `https://bitbucket.example.com`).                         |

### Workflow Modifications

**For GHES**:

1. Update the `ghes-ssh-host` in
   [.github/workflows/migration-github-enterprise-server.yml#L13](/.github/workflows/migration-github-enterprise-server.yml#L13)
   - it should be in the format of: `github.company.com`
2. Update the `user-mappings-source-url` in
   [.github/workflows/migration-github-enterprise-server.yml#L23](/.github/workflows/migration-github-enterprise-server.yml#L23)
   - it should be in the format of: `https://github.example.com`

**For GitLab**:

1. Update the GitLab URL for internal GitLab migrations in
   [.github/workflows/migration-external-gitlab.yml#L21](/.github/workflows/migration-external-gitlab.yml#L21)
2. Update the GitLab URL for external GitLab migrations in
   [.github/workflows/migration-internal-gitlab.yml#L24](/.github/workflows/migration-internal-gitlab.yml#L24)

**For GEI**:

1. If not running on a Ubuntu runner, or if you don't want to automatically
   install the pre-requisites, switch the `env.INSTALL_PREREQS` to `'false'` in
   [.github/workflows/shared-github-enterprise-cloud-gei.yml#L26](/.github/workflows/shared-github-enterprise-cloud-gei.yml#L26)
2. Ensure that the `GHES_ADMIN_TOKEN` has the
   [appropriate PAT scopes](https://docs.github.com/en/early-access/enterprise-importer/preparing-to-migrate-with-github-enterprise-importer/managing-access-for-github-enterprise-importer#required-scopes-for-personal-access-tokens)
   for running a migration (source organization) or has been
   [granted the migrator role](https://docs.github.com/en/early-access/enterprise-importer/preparing-to-migrate-with-github-enterprise-importer/granting-the-migrator-role)
3. Note that the `/delete-repositories` functionality does not work for cleaning
   up GEI-migrated repositories
