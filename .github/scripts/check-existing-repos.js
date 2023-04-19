module.exports = async ({github, context, options, core}) => {
  const duplicates = []

  options.repositories.forEach(async repository => {
    try {
      await github.rest.repos.get({
        owner: options.targetOrganization,
        repo: repository.split(',')[1],
      })
    } catch (error) {
      duplicates.push(repository)
    }
  })

  if (duplicates.length !== 0) {
    let commentBody = `:no_entry: **Validation failed.** One or more repositories already exist:

    \`\`\`plain
    ${duplicates.join('\n')}
    \`\`\`

    Please remove the duplicates from your issue body and try again.
    `

    await github.rest.issues.createComment({
      issue_number: context.issue.number,
      owner: context.repo.owner,
      repo: context.repo.repo,
      commentBody,
    })

    core.setFailed(`Validation failed. One or more repositories already exist.`)
  }
}
