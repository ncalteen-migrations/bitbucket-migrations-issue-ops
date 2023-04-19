module.exports = ({context, core}) => {
  const issueBody = context.payload.issue.body
  const parsedIssueBody = issueBody.match(
    /### Repositories\s+```CSV(?<repositories>[^`]+)```\s+### Target repository visibility\s+(?<targetRepositoryVisibility>Private|Internal)/,
  )

  if (parsedIssueBody) {
    const repositories = lines(parsedIssueBody.groups.repositories.trim())

    core.setOutput('repositories-json', JSON.stringify(repositories))
    core.setOutput('repositories', parsedIssueBody.groups.repositories)
    core.setOutput(
      'target-visibility',
      parsedIssueBody.groups.targetRepositoryVisibility,
    )

    return parsedIssueBody.groups
  }
}
