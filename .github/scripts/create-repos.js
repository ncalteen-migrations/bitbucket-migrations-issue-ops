module.exports = async ({github, context, core, options}) => {
  console.log(options.repositories)
  options.repositories.forEach(async repository => {
    await github.rest.repos.createInOrg({
      org: options.targetOrganization,
      name: repository.split(',')[1],
      visibility:
        options.targetRepositoryVisibility === 'Private'
          ? 'private'
          : 'internal',
    })
  })
}
