module.exports = async ({github, context, core, options}) => {
  options.repositories.forEach(async repository => {
    await github.rest.repos.delete({
      owner: options.targetOrganization,
      repo: repository.split(',')[1],
    })
  })
}
