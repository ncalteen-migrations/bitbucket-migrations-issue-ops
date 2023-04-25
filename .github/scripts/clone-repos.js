/**
 * Creates repositories in the organization based on the number of teams.
 */
module.exports = async ({github, context, core, options, exec}) => {
  let targetRepositoryUrl
  let sourceRepositoryUrl
  let repo

  // Create a temporary directory to clone the source repositories
  await exec.exec(`mkdir ${options.temp}/repository`)

  options.repositories.forEach(repository => {
    repo = repository.split(',')
    sourceRepositoryUrl = `https://x-token-auth:${process.env.BITBUCKET_CLOUD_ADMIN_TOKEN}@bitbucket.org/${process.env.BITBUCKET_CLOUD_WORKSPACE}/${repo}.git`
    targetRepositoryUrl = `https://${process.env.GHEC_ADMIN_TOKEN}@github.com/${options.targetOrganization}/${repo}.git`

    // Clone the source repository
    exec
      .exec(`git clone --mirror ${sourceRepositoryUrl}`, [], {
        cwd: `${options.temp}`,
      })
      .then(() => {
        core.info(`Repository cloned: ${repo}`)

        // Push the source repository to the target repository
        exec
          .exec(`git push --mirror ${targetRepositoryUrl}`, [], {
            cwd: `${options.temp}/${repo}`,
          })
          .then(async () => {
            core.info(`Repository mirrored: ${repo}`)

            // Empty the temporary directory
            exec.exec(`rm -rf .`, [], {
              cwd: `${options.temp}/${repo}`,
            })
          })
      })
  })
}
