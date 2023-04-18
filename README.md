# Migrate from Bitbucket to GitHub.com

> **Note:** This README file is for end-users who will be interacting with the
> migration issue ops. For setup/administration of this repository, refer to the
> [ADMIN_README.md](./ADMIN_README.md).

<!-- TODO Items
1. Determine if this will handle BB Cloud and BB Server
--->

## Overview

This migration utility has been tested for the following migration paths:

1. Bitbucket Server v7.1.1 -> GitHub Enterprise Cloud (GHEC)
2. Bitbucket Cloud -> GitHub Enterprise Cloud (GHEC)

## Considerations

- When migrating from Bitbucket Cloud, only commit history is included. Other
  metadata is not supported at this time.
- Migrating user-owned repositories is not supported. To migrate a user-owned
  repository, you must transfer it to a non-user owner before performing the
  migration.

## Step 1: Create a user mapping file

> **Note:** Any users in the mapping file must exist in your GitHub enterprise
> before attempting to migrate!

In order to migrate commit history and reattribute commits to the correct users,
you must create and maintain a user mapping file in this repository. The
[`user-mappings.csv`](./user-mappings.csv) file contains a mapping of source
users (Bitbucket) to target users (GHEC).

The user mapping file should follow the below format:

```csv
source,target
my-bitbucket-handle,my-ghec-handle
```

To do edit this mapping, create a pull request to the `main` branch of this
repository with any changes to the file.

## Step 2: Create a migration issue

1. Select the **Issues** tab.
2. Select **New issue**.
3. Select the appropriate issue template depending on the source you are
   migrating from (Bitbucket Server vs. Bitbucket Cloud).

   - [Migrate from Bitbucket Server](#todo)
   - [Migrate from Bitbucket Cloud](#todo)

4. In the **Repositories** text field, enter the list of repositories to migrate
   in the following format:

   ```csv
   PROJECT_1_KEY,repo_1_name
   PROJECT_2_KEY,repo_2_name
   ```

   > **Note**: You can specify multiple repositories in one issue.

5. In the **Target repository visibility** drop-down menu, select **Private** or
   **Internal**. This will set the visibility of the repository once it is
   migrated to GitHub.

Once the issue is created, GitHub Actions will validate the input and add a
comment to the issue summarizing the migration that will take place.

## Step 3: Perform a dry-run migration

A dry-run migration is highly recommended. Performing a dry-run will ensure that
any issues can be caught and resolved before the production migration begins.
Dry-run migrations will not lock the source repository. Users will be able to
continue working on the repository until you initiate the production migration.

1. Open the migration issue you created previously.
2. Add the following comment to initiate a dry-run migration:

   ```plain
   /run-dry-run-migration
   ```

## Step 4: Verify the dry-run migration

When the dry-run completes, you will be able to review the migration logs and
the repositories themselves. This is an important step to verify that all
objects were migrated successfully, user contributions were mapped to correct
accounts, etc.

<!-- TODO: Expand this -->

1. Review the migration logs
2. Review the repository contents:
   - Commits
   - Issues
   - Pull requests
   - Labels
   - Other metadata
   - Settings

Once you have completed your review, delete the migrated repositories before
starting the production migration. This can be done by adding a comment to the
migration issue.

1. Open the migration issue you created previously.
2. Add the following comment, replacing `MIGRATION_GUID` with the migration ID
   added to the issue comments:

   ```plain
   /delete-repositories MIGRATION_GUID
   ```

## Step 5: Perform the production migration

> **Note:** Make sure to communicate the timing of migration well ahead of time
> so that users can save/commit any work they do not want to lose.

After you have verified your dry-run migration and announced the production
migration to your users, you can initiate the production migration by adding a
comment to the migration issue.

1. Open the migration issue you created previously.
2. Add the following comment:

   ```plain
   /run-production-migration
   ```

The migration automation will take the following steps:

- Lock the source repositories.

<!-- TODO What else? -->

## Repo Setup Guide

When using this codebase to migrate repos in your own organization, here are a
few things that will need to be created/modified:

### Issue Labels

Create the following
[issue labels](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels#creating-a-label):

1. `github-enterprise-server` (for ghes)
2. `external-gitlab` (for gitlab)
3. `internal-gitlab` (for gitlab)
4. `migration` (for all)
5. `gei` (for ghes)

### Secrets

Create these
[secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)
on the repository that is hosting this migration utility:

| Secret                      | Description                                                                          | Needed For   |
| --------------------------- | ------------------------------------------------------------------------------------ | ------------ |
| GHEC_ADMIN_TOKEN            | PAT of account with permissions in target org in GitHub.com                          | GHES, GitLab |
| GHEC_TARGET_ORGANIZATION    | Name of target organization in GitHub.com (eg: `myorg`)                              | GHES, GitLab |
| GHES_ADMIN_USERNAME         | GitHub Enterprise server admin username                                              | GHES         |
| GHES_ADMIN_TOKEN            | GitHub Enterprise Server admin console password/token                                | GHES         |
| GITLAB_USERNAME             | GitLab username                                                                      | GitLab       |
| GITLAB_API_PRIVATE_TOKEN    | GitLab API Token                                                                     | GitLab       |
| GITLAB_API_ENDPOINT         | GitLab API URL without the slash at the end; eg: `https://gitlab.example.com/api/v4` | GitLab       |
| GEI_AZURE_CONNECTION_STRING | Connection string for an Azure storage account (required for GEI).                   | GHES         |

### Runner Setup

Configure a runner on the repository that can access the GitHub Enterprise
Server or GitLab instance.

For GHES: Add the machine's SSH public key SSH to the
[GitHub Enterprise Server admin console](https://docs.github.com/en/enterprise-server@3.4/admin/configuration/configuring-your-enterprise/accessing-the-administrative-shell-ssh#enabling-access-to-the-administrative-shell-via-ssh).
The script needs to be able to SSH into the GitHub Enterprise Server instance.
Instructions on creating and/or exporting the public key are below:

- [Creating public key](https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key)
- Export public key to console: `cat ~/.ssh/id_rsa.pub`

If necessary, update the self-hosted runner label in
[.github/workflows/migration-github-enterprise-server.yml#L12](/.github/workflows/migration-github-enterprise-server.yml#L12)
so that it picks up the designated runner - the runner label otherwise defaults
to `self-hosted`.

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

### Note on GitLab Exports

Working through the `gl-exporter` ruby runtime
[requirements](/tools/gl-exporter/docs/Requirements.md) can sometimes be tricky.
It's possible to build and push the [Dockerfile](/tools/gl-exporter/Dockerfile)
to the repository and run as a container job:

```
jobs:
  export:
    name: Export
    runs-on: ${{ inputs.runner }}
    container:
      image: 'ghcr.io/${{ github.repository }}:latest'
      credentials:
         username: ${{ github.ref }}
         password: ${{ secrets.GITHUB_TOKEN }}
```

### Note on Tools

This repo isn't intended to have the latest copies of the
[ghec-importer](https://github.com/github/ghec-importer) and
[gl-exporter](https://github.com/github/gl-exporter). If desired, grab the
latest versions of the code and update the copy in the `./tools` directory.
