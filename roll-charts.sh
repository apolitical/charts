#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

GIT_REPO=`git remote -v | awk '{ print $2 }' | head -n 1`
BUILD_DIR="${PWD}/build"
CHARTS_DIR="${PWD}/charts"

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
      helm package "${package_name}" -d "${BUILD_DIR}"
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

(
    cd ${BUILD_DIR}

    if [ `git status -s | grep -v index.yaml` ]; then
        echo "Committing"
        git add .
        DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
        git commit -m "Build ${DATE}"
        echo "Done"
    else
        echo "No changes"
    fi
)
