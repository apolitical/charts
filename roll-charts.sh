#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

get_gpg_key() {
  KEY_NAME=${1:-}
  if [ ! -z "${KEY_NAME}" ]; then
    KEY=`gpg --list-keys ${KEY_NAME} | head -n 2 | tail -n 1 | awk '{ print $1 }'`
  else
    KEY=`gpgconf --list-options gpg | awk -F: '$1 == "default-key" {print $10}'`
  fi
  echo ${KEY}
}

BUILD_DIR="${PWD}/build"
CHARTS_DIR="${PWD}/charts"
GIT_REPO=`git remote -v | awk '{ print $2 }' | head -n 1`
KEY_NAME=${1:-}
GPG_KEY=$(get_gpg_key "${KEY_NAME}")
if [ -z "${GPG_KEY}" ]; then
    echo "No GPG key found!"
    echo "Either set a default key in GPG or specify one when running this command:"
    echo
    echo "Eg:"
    echo "./roll-charts.sh daniel.mason@apolitical.co"
    exit 1
fi

echo
echo "Configuring build directory"
echo "==========================="
echo

(
    if [ ! -d "build" ]; then
        echo "Collecting user data"
        USER_INFO=`git config --list | grep "^user."`

        echo "Cloning repository"
        git clone "${GIT_REPO}" "${BUILD_DIR}";
        cd ${BUILD_DIR};

        echo "Switching to gh-pages"
        git checkout gh-pages

        echo "Configuring user"
        while read -r config_entry; do
            IFS='=' read -r -a parts <<< "${config_entry}"
            KEY=${parts[0]}
            VALUE=${parts[1]}
            git config --local --add ${KEY} "${VALUE}"
        done <<< "$USER_INFO"

        echo "Done"
    else
        echo "Probably configured already ¯\_(ツ)_/¯"
        echo "If build fails, delete the build dir and rerun"
    fi
)

echo
echo "Updating dependencies"
echo "====================="
echo
echo "ToDo: Update dependencies, if any"

echo
echo "Generating charts"
echo "================="
echo

(
    cd ${CHARTS_DIR}
    for package_name in *; do
      helm package "${package_name}" -d "${BUILD_DIR}" --sign --key "${GPG_KEY}"
    done

    echo "Indexing"
    cd ${BUILD_DIR}
    helm repo index .
    echo "Done"
)

echo
echo "Creating repo index"
echo "==================="
echo

(
    echo "Indexing"
    cd ${BUILD_DIR}
    helm repo index .
    echo "Done"
)

echo
echo "Committing changes"
echo "=================="
echo

#(
#    cd ${BUILD_DIR}
#
#    if [ `git status -s | grep -v index.yaml` ]; then
#        echo "Committing"
#        git add .
#        DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
#        git commit -m "Build ${DATE}"
#        echo "Done"
#    else
#        echo "No changes"
#    fi
#)
