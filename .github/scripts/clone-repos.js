/**
 * Creates repositories in the organization based on the number of teams.
 */
module.exports = async ({github, context, core, options, exec}) => {
  let targetRepositoryUrl
  let sourceRepositoryUrl

  // Create a temporary directory to clone the source repositories
  await exec.exec(`mkdir ${options.temp}/repository`)

  options.repositories.forEach(repository => {
    sourceRepositoryUrl = `https://x-token-auth:${process.env.BITBUCKET_CLOUD_ADMIN_TOKEN}@bitbucket.org/${process.env.BITBUCKET_CLOUD_WORKSPACE}/${repository}.git`
    targetRepositoryUrl = `https://${process.env.GHEC_ADMIN_TOKEN}@github.com/${options.targetOrganization}/${repository}.git`

    // Clone the source repository
    exec
      .exec(`git clone --mirror ${sourceRepositoryUrl}`, [], {
        cwd: `${options.temp}`,
      })
      .then(() => {
        core.info(`Repository cloned: ${repository}`)

        // Push the source repository to the target repository
        exec
          .exec(`git push --mirror ${targetRepositoryUrl}`, [], {
            cwd: `${options.temp}/${repository}`,
          })
          .then(async () => {
            core.info(`Repository mirrored: ${repository}`)

            // Empty the temporary directory
            exec.exec(`rm -rf .`, [], {
              cwd: `${options.temp}/${repository}`,
            })
          })
      })
  })
}
