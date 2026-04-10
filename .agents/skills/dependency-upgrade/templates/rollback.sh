#!/usr/bin/env bash
# upgrade-with-rollback.sh
#
# Usage:
#   ./upgrade-with-rollback.sh <package> <target-version> <build-and-test-command>
#
# Examples:
#   ./upgrade-with-rollback.sh spring-boot 3.2.0 "./gradlew build"
#   ./upgrade-with-rollback.sh django 5.0.0 "pytest"
#   ./upgrade-with-rollback.sh react 18.0.0 "npm test"
#
# The script:
#   1. Creates a branch for the upgrade
#   2. Bumps the version (manual step — see instructions in script)
#   3. Runs the provided build-and-test command
#   4. Commits on success or rolls back on failure

set -euo pipefail

PACKAGE="${1:?Usage: $0 <package> <target-version> <build-and-test-command>}"
TARGET_VERSION="${2:?Usage: $0 <package> <target-version> <build-and-test-command>}"
TEST_COMMAND="${3:?Usage: $0 <package> <target-version> <build-and-test-command>}"

BRANCH="upgrade/${PACKAGE}-${TARGET_VERSION}"
ORIGINAL_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

cleanup() {
  local exit_code=$?
  if [ $exit_code -ne 0 ]; then
    echo ""
    echo "ERROR: upgrade failed (exit code $exit_code)"
    echo "Rolling back to ${ORIGINAL_BRANCH}..."
    git checkout "${ORIGINAL_BRANCH}"
    if git branch --list "${BRANCH}" | grep -q "${BRANCH}"; then
      git branch -D "${BRANCH}"
      echo "Deleted branch ${BRANCH}"
    fi
    echo ""
    echo "Rollback complete. Restore lockfile with the appropriate command for your ecosystem:"
    echo "  npm:     git checkout package-lock.json && npm ci"
    echo "  yarn:    git checkout yarn.lock && yarn install --frozen-lockfile"
    echo "  pip:     git checkout requirements.txt && pip install -r requirements.txt"
    echo "  poetry:  git checkout poetry.lock && poetry install"
    echo "  gradle:  git checkout libs.versions.toml build.gradle.kts"
    echo "  maven:   git checkout pom.xml"
    echo "  go:      git checkout go.mod go.sum && go mod download"
    echo "  cargo:   git checkout Cargo.lock && cargo fetch"
    echo "  bundler: git checkout Gemfile.lock && bundle install"
  fi
}
trap cleanup EXIT

echo "==> Creating branch: ${BRANCH}"
git checkout -b "${BRANCH}"

echo ""
echo "==> MANUAL STEP: Update '${PACKAGE}' to version '${TARGET_VERSION}' in your manifest."
echo "    Edit the appropriate file for your ecosystem:"
echo "      - Maven:   pom.xml"
echo "      - Gradle:  libs.versions.toml or build.gradle.kts"
echo "      - pip:     requirements.txt or pyproject.toml"
echo "      - poetry:  pyproject.toml, then run: poetry update ${PACKAGE}"
echo "      - npm:     run: npm install ${PACKAGE}@${TARGET_VERSION}"
echo "      - go:      run: go get ${PACKAGE}@v${TARGET_VERSION} && go mod tidy"
echo "      - cargo:   Cargo.toml"
echo "      - nuget:   run: dotnet add package ${PACKAGE} --version ${TARGET_VERSION}"
echo ""
read -r -p "Press ENTER once you have updated the version declaration..."

echo ""
echo "==> Running: ${TEST_COMMAND}"
if eval "${TEST_COMMAND}"; then
  echo ""
  echo "==> Tests passed. Committing..."
  git add -A
  git commit -m "chore(deps): upgrade ${PACKAGE} to ${TARGET_VERSION}"
  echo ""
  echo "SUCCESS: Upgrade committed on branch '${BRANCH}'."
  echo "Next step: open a pull request from '${BRANCH}' into '${ORIGINAL_BRANCH}'."
  # Suppress the trap cleanup on success
  trap - EXIT
else
  echo ""
  echo "==> Tests FAILED."
  exit 1
fi
