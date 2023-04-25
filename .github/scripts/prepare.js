const parseIssueBody = require('./parse-issue-body.js')

module.exports = async ({github, context, core, options}) => {
  const {repositories, targetRepositoryVisibility} = parseIssueBody({
    context,
    core,
  })

  let body

  if (repositories && targetRepositoryVisibility) {
    repositories = repositories.trim().split('\n')

    body = `👋 Thank you for opening this migration issue!
  
    The following **${repositories.length} repositories** have been parsed from your issue body:
  
    \`\`\`plain
    ${repositories}
    \`\`\`
  
    The **target organization** is set to: **\`${options.targetOrganization}\`**

    The **target repository visibility** is set to: **\`${targetRepositoryVisibility}\`**
  
    <details>
      <summary>
        <b>Troubleshooting</b>
      </summary>
  
      If the parsed repositories do not match the repositories listed in your issue body, you can edit the issue body and make sure it's correct.
    </details>
  
    ## Run the migration
  
    Add a comment to this issue with one of the following two commands in order to run a migration:
  
    **Dry-run**
  
    We recommend to do a "dry-run" migration first which **will not lock your source repository**. Users may continue working on the repository.
  
    \`\`\`plain
    /run-dry-run-migration
    \`\`\`
  
    **Production**
  
    After you have verified your "dry-run" migration and after you have announced the production migration to your users, add a comment with the following command to start the production migration. It **will lock your source repository** and make it unaccessible for your users.
  
    \`\`\`plain
    /run-production-migration
    \`\`\`
    `
  } else {
    core.setFailed('The issue body could not be parsed')
  }

  await github.rest.issues.createComment({
    issue_number: context.issue.number,
    owner: context.repo.owner,
    repo: context.repo.repo,
    body: body,
  })
}
