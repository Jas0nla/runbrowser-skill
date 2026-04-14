#!/bin/zsh

set -euo pipefail

REPO_URL="${RUNBROWSER_REPO_URL:-https://github.com/runbrowser/runbrowser.git}"
TARGET_DIR="${1:-$HOME/runbrowser-upstream}"

if ! command -v git >/dev/null 2>&1; then
  echo "Missing required command: git" >&2
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "Missing required command: pnpm" >&2
  exit 1
fi

if [[ -d "${TARGET_DIR}/.git" ]]; then
  echo "Using existing repo at ${TARGET_DIR}"
  git -C "${TARGET_DIR}" pull --ff-only
else
  echo "Cloning RunBrowser repo into ${TARGET_DIR}"
  git clone "${REPO_URL}" "${TARGET_DIR}"
fi

cd "${TARGET_DIR}"

echo "Installing workspace dependencies..."
pnpm install

echo "Building extension workspace dependency..."
pnpm --filter vite-plugin-extension-reload build

echo "Building Chrome extension..."
pnpm run build:extension

DIST_DIR="${TARGET_DIR}/packages/extension/dist"

if [[ ! -f "${DIST_DIR}/manifest.json" ]]; then
  echo "Expected extension build output missing: ${DIST_DIR}/manifest.json" >&2
  exit 1
fi

echo
echo "RunBrowser extension is ready."
echo "Load this folder in Chrome:"
echo "${DIST_DIR}"
