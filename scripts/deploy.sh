#! /usr/bin/env bash

VERSION=$1
NPM_TAG=$2

# install dependencies
npm ci

# setup configuration
git config user.name $GITHUB_ACTOR
git config user.email gh-actions-${GITHUB_ACTOR}@github.com
git remote add gh-origin git@github.com:${GITHUB_REPOSITORY}.git
npm config set //registry.npmjs.org/:_authToken=${NPM_TOKEN}

# update version in package.json and package-lock.json
npm version ${VERSION} --git-tag-version=false
git add package.json package-lock.json
git commit -m "[skip ci] ${VERSION}"

# publish the package to NPM if it hasn't already been published
if [[ -z "$(npm view @adobe/alloy@${VERSION})" ]]; then
  echo "Publishing to NPM"
  npm publish --access public --tag $NPM_TAG
else
  echo "NPM already has version ${VERSION}"
fi

# update reference to NPM version
npm install @adobe/alloy@${VERSION} --save-dev
git add package.json package-lock.json

# tag and push the release
# [skip ci] disables the triggering of github workflows on this push
# https://github.blog/changelog/2021-02-08-github-actions-skip-pull-request-and-push-workflows-with-skip-ci/
git commit -m "[skip ci] update self devDependency to ${VERSION}"
git tag -a "v${VERSION}" -m "${VERSION}"
git push gh-origin HEAD:${GITHUB_REF} --follow-tags

# build alloy.js and alloy.min.js
npm run build

# upload alloy.js and alloy.min.js to CDN
./scripts/sftpCommands.sh ${VERSION} | \
  sftp -oHostKeyAlgorithms=+ssh-dss -oStrictHostKeyChecking=no -b - sshacs@dxresources.ssh.upload.akamai.com:/prod/alloy

# verify the files are available on the cdn
ALLOY_MIN_JS="https://cdn1.adoberesources.net/alloy/${VERSION}/alloy.min.js"
STATUS_CODE=$(curl -o /dev/null -Isw '%{http_code}\n' $ALLOY_MIN_JS)
if [ $STATUS_CODE != "200" ]; then
  echo "curl request to $ALLOY_MIN_JS returned status code $STATUS_CODE" 1>&2
  exit 1
fi

ALLOY_JS="https://cdn1.adoberesources.net/alloy/${VERSION}/alloy.js"
STATUS_CODE=$(curl -o /dev/null -Isw '%{http_code}\n' $ALLOY_JS)
if [ $STATUS_CODE != "200" ]; then
  echo "curl request to $ALLOY_JS returned status code $STATUS_CODE" 1>&2
  exit 1
fi

echo "Verified files are available on CDN"
