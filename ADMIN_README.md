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

| Secret                     | Description                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------ |
| `GHEC_ADMIN_TOKEN`         | Personal access token with admin permissions in the target GitHub Enterprise organization. |
| `GHEC_TARGET_ORGANIZATION` | The name of the target organization to migrate into.                                       |
| `BBS_ADMIN_TOKEN`          | Bitbucket Server HTTP access token with project and repository admin permissions.          |
| `BBS_URL`                  | Bitbucket Server URL, no trailing slash (e.g. `https://bitbucket.example.com`).            |
