module.exports = ({context, core}) => {
  const issueBody = context.payload.issue.body
  const parsedIssueBody = issueBody.match(
    /### Repositories\s+```CSV(?<repositories>[^`]+)```\s+### Target repository visibility\s+(?<targetRepositoryVisibility>Private|Internal)/,
  )

  console.log(parsedIssueBody)

  if (parsedIssueBody) {
    const repositories = parsedIssueBody.groups.repositories.trim().split('\n')

    core.setOutput('repositories-json', JSON.stringify(repositories))
    core.setOutput('repositories', parsedIssueBody.groups.repositories)
    core.setOutput(
      'target-visibility',
      parsedIssueBody.groups.targetRepositoryVisibility,
    )

    return parsedIssueBody.groups
  }
}
