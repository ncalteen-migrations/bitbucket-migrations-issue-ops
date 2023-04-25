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

| Secret                       | Description                                                                                |
| ---------------------------- | ------------------------------------------------------------------------------------------ |
| `GHEC_ADMIN_TOKEN`           | Personal access token with admin permissions in the target GitHub Enterprise organization. |
| `BITBUCKET_SERVER_API_TOKEN` | Bitbucket Server HTTP access token with project and repository admin permissions.          |
| `BITBUCKET_CLOUD_API_TOKEN`  | Bitbucket Cloud HTTP access token with project and repository admin permissions.           |

### Variables

Create the following variables in the repository that is hosting this utility.
See
[Variables](https://docs.github.com/en/actions/learn-github-actions/variables)
for instructions.

| Secret                      | Description                                                                                                                               |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `GHEC_TARGET_ORGANIZATION`  | The name of the target organization to migrate into.                                                                                      |
| `BITBUCKET_SERVER_URL`      | Bitbucket Server URL, no trailing slash (e.g. `https://bitbucket.example.com`).                                                           |
| `BITBUCKET_CLOUD_WORKSPACE` | The name of the Bitbucket Cloud workspace (e.g. `ncalteen-github` in the url `https://bitbucket.org/ncalteen-github/workspace/overview`). |
