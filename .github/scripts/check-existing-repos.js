const fs = require('fs')

module.exports = async ({github, context, options, core}) => {
  const repositories = fs
    .readFileSync('../repositories.txt', 'utf8')
    .split('\n')

  let duplicates = []

  repositories.forEach(repository => {
    github.rest.repos
      .get({
        owner: options.targetOrganization,
        repo: repository.split(',')[1],
      })
      .catch(() => {
        duplicates.push(repo)
      })
  })

  if (duplicates.length > 0) {
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
