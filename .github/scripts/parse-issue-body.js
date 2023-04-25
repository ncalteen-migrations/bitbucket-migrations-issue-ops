module.exports = ({github, context, core, options}) => {
  const issueBody = context.payload.issue.body
  const parsedIssueBody = issueBody.match(
    /### Repositories[\r\n]+```CSV[\r\n]+(?<repositories>[^`]+)```[\r\n]+### Target repository visibility[\r\n]+(?<targetRepositoryVisibility>Private|Internal|None)/,
  )

  if (parsedIssueBody) {
    const repositories = parsedIssueBody.groups.repositories
      .trim()
      .split(/[\r\n]+/)

    core.setOutput('repositories-json', JSON.stringify(repositories))
    core.setOutput('repositories', parsedIssueBody.groups.repositories)
    core.setOutput(
      'target-visibility',
      parsedIssueBody.groups.targetRepositoryVisibility,
    )

    return parsedIssueBody.groups
  }
}
