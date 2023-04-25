/**
 * Creates repositories in the organization based on the number of teams.
 */
module.exports = async ({github, context, core, options, exec}) => {
  const BELT_REPO_MAP = require('./belt-repo-map.js')

  let targetRepositoryUrl

  // Create a temporary directory to clone the source repository
  await exec.exec(`mkdir ${options.temp}/repository`)

  // Clone the source repository
  const sourceRepositoryUrl = `https://${
    process.env.DOJO_GITHUB_TOKEN
  }@github.com/${BELT_REPO_MAP[options.belt].organization}/${
    BELT_REPO_MAP[options.belt].repository
  }.git`
  await exec.exec(`git clone --mirror ${sourceRepositoryUrl} .`, [], {
    cwd: `${options.temp}/repository`,
  })

  // Delete unwanted refs (PRs, tags, etc.)
  let refs = ''

  await exec.exec(
    'git for-each-ref --format "%(refname)" refs/pull refs/tags refs/heads/users refs/heads/dependabot',
    [],
    {
      cwd: `${options.temp}/repository`,
      listeners: {
        stdout: data => {
          refs += data.toString()
        },
      },
    },
  )

  let promises = []

  core.info('Deleting refs:')
  core.info(refs)
  refs.split('\n').forEach(async ref => {
    if (ref !== '') {
      promises.push(
        exec.exec(`git update-ref -d ${ref}`, [], {
          cwd: `${options.temp}/repository`,
        }),
      )
    }
  })

  // Push the source repository to the new repositories
  Promise.all(promises).then(() => {
    options.repositories.forEach(async repository => {
      core.info(`Mirroring repository: ${repository}`)

      targetRepositoryUrl = `https://${process.env.DOJO_GITHUB_TOKEN}@github.com/${options.organization}/${repository}.git`

      await exec.exec(`git push --mirror ${targetRepositoryUrl}`, [], {
        cwd: `${options.temp}/repository`,
      })
    })
  })
}
