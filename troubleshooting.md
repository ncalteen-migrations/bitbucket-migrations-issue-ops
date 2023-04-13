# Troubleshooting

## Bitbucket

### Import of large archive fails due to timeout

Consider splitting the export by changing the workflows to perform the export in
two steps, and then import each portion separately.

1. Update
   [`shared-bitbucket-server-export.yml`](.github/workflows/shared-bitbucket-server-export.yml)
   to export the repositories and metadata separately.

   ```yaml
   # Replace this
   - name: Export from Bitbucket Server
     run: bbs-exporter -f repositories.txt -o ${MIGRATION_GUID}.tar.gz

   - name: Upload migration archive to GitHub Artifacts
     uses: actions/upload-artifact@v3
     with:
       name: ${{ env.MIGRATION_GUID }}.tar.gz
       path: ${{ github.workspace }}/${{ env.MIGRATION_GUID }}.tar.gz
       if-no-files-found: error
       retention-days: 1

   # With this
   - name: Export repositories from Bitbucket Server
     run:
       bbs-exporter --only repository --max-threads 25 --retries 5 -f
       repositories.txt -o ${MIGRATION_GUID}_repos.tar.gz

   - name: Export metadata from Bitbucket Server
     run:
       bbs-exporter --except repository --max-threads 25 --retries 5 -f
       repositories.txt -o ${MIGRATION_GUID}_meta.tar.gz

   - name: Upload repository migration archive to GitHub Artifacts
     uses: actions/upload-artifact@v3
     with:
       name: ${{ env.MIGRATION_GUID }}_repos.tar.gz
       path: ${{ github.workspace }}/${{ env.MIGRATION_GUID }}_repos.tar.gz
       if-no-files-found: error
       retention-days: 1

   - name: Upload metadata migration archive to GitHub Artifacts
     uses: actions/upload-artifact@v3
     with:
       name: ${{ env.MIGRATION_GUID }}_meta.tar.gz
       path: ${{ github.workspace }}/${{ env.MIGRATION_GUID }}_meta.tar.gz
       if-no-files-found: error
       retention-days: 1
   ```

2. Update
   [`shared-github-enterprise-cloud-import.yml`](.github/workflows//shared-github-enterprise-cloud-import.yml)
   to import the repositories and metadata separately.

   First, update the file to download both archives.

   ```yaml
   # Replace this
   - name: Download migration archive
     uses: actions/download-artifact@v3
     with:
       name: ${{ env.MIGRATION_GUID }}.tar.gz

   # With this
   - name: Download migration archive
     uses: actions/download-artifact@v3
     with:
       name: ${{ env.MIGRATION_GUID }}_repos.tar.gz

   - name: Download migration archive
     uses: actions/download-artifact@v3
     with:
       name: ${{ env.MIGRATION_GUID }}_meta.tar.gz
   ```

   Next, update the import step to import both archives.

   ```yaml
   # Replace this
   - name: Run import
     id: import
     run: ghec-importer import ../../${{ env.MIGRATION_GUID }}.tar.gz --debug
     env:
       GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
       GHEC_IMPORTER_ADMIN_TOKEN: ${{ secrets.GHEC_ADMIN_TOKEN }}
       GHEC_IMPORTER_TARGET_ORGANIZATION:
         ${{ secrets.GHEC_TARGET_ORGANIZATION }}
       GHEC_IMPORTER_RESOLVE_REPOSITORY_RENAMES: guid-suffix
       GHEC_IMPORTER_DISALLOW_TEAM_MERGES: true
       GHEC_IMPORTER_USER_MAPPINGS_PATH: ../../subset-user-mappings.csv
       GHEC_IMPORTER_USER_MAPPINGS_SOURCE_URL:
         ${{ inputs.user-mappings-source-url }}
       GHEC_IMPORTER_MAKE_INTERNAL:
         ${{ steps.parse.outputs.target-visibility == 'Internal' }}
       # Terminate process with non-zero exit code if file system operations
       # fail (https://nodejs.org/api/cli.html#cli_unhandled_rejections_mode)
       NODE_OPTIONS: --unhandled-rejections=strict

   # With this
   - name: Run repository import
     id: import
     run:
       ghec-importer import ../../${{ env.MIGRATION_GUID }}_repos.tar.gz --debug
     env:
       GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
       GHEC_IMPORTER_ADMIN_TOKEN: ${{ secrets.GHEC_ADMIN_TOKEN }}
       GHEC_IMPORTER_TARGET_ORGANIZATION:
         ${{ secrets.GHEC_TARGET_ORGANIZATION }}
       GHEC_IMPORTER_RESOLVE_REPOSITORY_RENAMES: guid-suffix
       GHEC_IMPORTER_DISALLOW_TEAM_MERGES: true
       GHEC_IMPORTER_USER_MAPPINGS_PATH: ../../subset-user-mappings.csv
       GHEC_IMPORTER_USER_MAPPINGS_SOURCE_URL:
         ${{ inputs.user-mappings-source-url }}
       GHEC_IMPORTER_MAKE_INTERNAL:
         ${{ steps.parse.outputs.target-visibility == 'Internal' }}
       # Terminate process with non-zero exit code if file system operations
       # fail (https://nodejs.org/api/cli.html#cli_unhandled_rejections_mode)
       NODE_OPTIONS: --unhandled-rejections=strict

   - name: Run metadata import
     id: import
     run:
       ghec-importer import ../../${{ env.MIGRATION_GUID }}_meta.tar.gz --debug
     env:
       GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
       GHEC_IMPORTER_ADMIN_TOKEN: ${{ secrets.GHEC_ADMIN_TOKEN }}
       GHEC_IMPORTER_TARGET_ORGANIZATION:
         ${{ secrets.GHEC_TARGET_ORGANIZATION }}
       GHEC_IMPORTER_RESOLVE_REPOSITORY_RENAMES: guid-suffix
       GHEC_IMPORTER_DISALLOW_TEAM_MERGES: true
       GHEC_IMPORTER_USER_MAPPINGS_PATH: ../../subset-user-mappings.csv
       GHEC_IMPORTER_USER_MAPPINGS_SOURCE_URL:
         ${{ inputs.user-mappings-source-url }}
       GHEC_IMPORTER_MAKE_INTERNAL:
         ${{ steps.parse.outputs.target-visibility == 'Internal' }}
       # Terminate process with non-zero exit code if file system operations
       # fail (https://nodejs.org/api/cli.html#cli_unhandled_rejections_mode)
       NODE_OPTIONS: --unhandled-rejections=strict
   ```
