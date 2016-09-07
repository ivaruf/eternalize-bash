#!/bin/bash

# "Force push" for when you have people who freak out
# When they see a branch was forcably updated.
# What you do with your feature branch is your business!

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

git push origin --delete ${CURRENT_BRANCH}
git push -u origin ${CURRENT_BRANCH}

