module.exports = async ({github, context, core, options}) => {
  async function checkDuplicate(repository) {
    try {
      console.log(`Checking ${repository}...`)
      await github.rest.repos.get({
        owner: options.targetOrganization,
        repo: repository.split(',')[1],
      })

      return true
    } catch (error) {
      console.log(error)
      return false
    }
  }

  const promises = options.repositories.map(checkDuplicate)

  Promise.all(promises).then(values => {
    const duplicates = []

    values.forEach((value, index) => {
      if (value) {
        duplicates.push(options.repositories[index])
      }
    })

    if (duplicates.length !== 0) {
      github.rest.issues
        .createComment({
          issue_number: context.issue.number,
          owner: context.repo.owner,
          repo: context.repo.repo,
          body: getCommentBody(duplicates),
        })
        .then(() => {
          core.setFailed(
            `Validation failed. One or more repositories already exist.`,
          )
        })
    }
  })
}

function getCommentBody(duplicates) {
  return `:no_entry: **Validation failed.** One or more repositories already exist:

  \`\`\`plain
  ${duplicates.join('\n')}
  \`\`\`

  Please remove the duplicates from your issue body and try again.
  `
}
