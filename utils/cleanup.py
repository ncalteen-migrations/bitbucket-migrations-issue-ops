""" Clean up local testing. """
import json
import os
import requests

# Set the correct owner and repo to clear logs for.
OWNER = 'bitbucket-migration'

# API call headers.
HEADERS = {
    'Accept': 'application/vnd.github+json',
    'Authorization': f'Bearer {os.environ.get("GITHUB_TOKEN")}'
}

########################################
#   Clean up old GitHub Actions logs   #
########################################
REPO = 'migrations-issue-ops'

# URL to list workflow runs.
url = f'https://api.github.com/repos/{OWNER}/{REPO}/actions/runs'

# Initial list of runs.
response = requests.request("GET", url, headers=HEADERS, data={})

while response.json().get('workflow_runs'):
  for run in response.json().get('workflow_runs'):
    # Delete the runs.
    delete_url = f'https://api.github.com/repos/{OWNER}/{REPO}/actions/runs/{run.get("id")}'
    _ = requests.request("DELETE", delete_url, headers=HEADERS, data={})

    print(f'Deleted run: {run.get("id")}')

    # Check if there are more runs to delete.
    response = requests.request("GET", url, headers=HEADERS, data={})

########################################
#          Delete repositories         #
########################################
url = f'https://api.github.com/orgs/{OWNER}/repos'

# Initial list of repos.
response = requests.request("GET", url, headers=HEADERS, data={})

while len(response.json()) > 1:
  for repo in response.json():
    if repo.get('name') != 'migrations-issue-ops':
      # Delete the repo.
      delete_url = f'https://api.github.com/repos/{OWNER}/{repo.get("name")}'
      _ = requests.request("DELETE", delete_url, headers=HEADERS, data={})

      print(f'Deleted repo: {repo.get("name")}')

      # Check if there are more repos to delete.
      response = requests.request("GET", url, headers=HEADERS, data={})
