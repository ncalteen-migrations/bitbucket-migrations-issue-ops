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

<!--2. Bitbucket Cloud -> GitHub Enterprise Cloud (GHEC)-->

## Considerations

<!--- When migrating from Bitbucket Cloud, only commit history is included. Other
  metadata is not supported at this time.-->

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
3. Select the **Bitbucket Server to GitHub Enterprise Cloud** issue.
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

Once the migration is complete, perform the same validation tasks you did after
the dry-run. After you are satisfied the repositories have been migrated
successfully, you can notify users that they are open for contribution.
