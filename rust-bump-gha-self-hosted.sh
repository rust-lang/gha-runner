#!/bin/bash
# This script updates the version number in rust-lang/gha-self-hosted after a
# release is made, removing the need for someone on the infrastructure team to
# bump the version number manually.
#
# It's executed by .github/workflows/release.yml

set -euo pipefail
IFS=$'\n\t'

repository_url="git@github.com:rust-lang/gha-self-hosted.git"
version_file="images/ubuntu/files/gha-runner-version"

git_name="rust-lang/gha-runner"
git_email="infra+gha-runner-automation@rust-lang.org"

# Load the deploy key on a temporary file.
key="$(mktemp)"
trap "rm ${key}" EXIT
echo "${DEPLOY_KEY}" > "${key}"

# Use the SSH key stored earlier for all git operations, and ignore ssh-agent.
export GIT_SSH_COMMAND="ssh -i ${key}"
unset SSH_AUTH_SOCK

# Clone the repository
clone="$(mktemp -d)"
trap "rm -rf ${clone}" EXIT
git clone "${repository_url}" "${clone}"

# Update the version file
version="$(cat releaseVersion)"
if [[ "$(cat "${clone}/${version_file}")" = "${version}" ]]; then
    echo "nothing to update, exiting"
else
    echo "${version}" > "${clone}/${version_file}"
    (
        cd "${clone}"
        git add .
        git \
            -c commit.gpgsign=false \
            -c "user.name=${git_name}" \
            -c "user.email=${git_email}" \
            commit -m "Bump the GitHub Actions runner to version ${version}"
        git push
    )
fi
