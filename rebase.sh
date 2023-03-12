#!/bin/bash

set -euxo pipefail

OLD_TAG=$1
NEW_TAG=$2

git fetch upstream
git fetch origin

git reset --hard origin/main

# this should fail, that's expected
git rebase --onto $NEW_TAG $OLD_TAG $OLD_TAG-rust1 || true

echo ${NEW_TAG/v/}-rust1 > src/runnerversion
echo ${NEW_TAG/v/}-rust1 > releaseVersion
echo "Fork of the GitHub Actions runner used by the Rust Infrastructure Team." > releaseNote.md
git add src/runnerversion releaseVersion releaseNote.md
git rebase --continue
git push -f origin HEAD:main
