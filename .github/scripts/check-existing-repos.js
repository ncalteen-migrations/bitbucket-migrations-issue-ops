const fs = require('fs')

module.exports = async ({github, context, options, core}) => {
  const duplicates = []

  options.repositories.forEach(repository => {
    console.log(
      `Checking if ${options.targetOrganization}/${
        repository.split(',')[1]
      } exists...`,
    )
    github.rest.repos
      .get({
        owner: options.targetOrganization,
        repo: repository.split(',')[1],
      })
      .then(response => {
        duplicates.push(repository)
        console.log(duplicates)
      })
      .catch(error => {
        // Do nothing
      })
  })

  console.log(duplicates)
  console.log(duplicates.length)

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
