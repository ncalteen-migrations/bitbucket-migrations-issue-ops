const fs = require('fs')

module.exports = async ({github, context, options}) => {
  const repositories = fs.readFileSync('./repositories.txt', 'utf8').split('\n')

  repositories.forEach(async repository => {
    await github.rest.repos.createInOrg({
      org: options.targetOrganization,
      name: repository.split(',')[1],
      private: true,
    })
  })

  // TODO: Change visibility of repo based on input in issue (read issue body)
}
