#!/usr/bin/env bash
# Termux first-run installer. Keep repository URL/branch in sync with the published repo.
set -eu
umask 077
REPO_URL='https://github.com/yeaminuli7/ai.git'
BRANCH='main'
PREFIX=${PREFIX:-}
# A proot often inherits PREFIX but its HOME is /root. Avoid mixing Android and Linux Python.
case "$PREFIX" in
  */com.termux/files/usr) ;;
  *) echo 'Error: run this in the standard Termux app, not Ubuntu/proot.' >&2; exit 1 ;;
esac
if [ "${HOME%/}" != "${PREFIX%/usr}/home" ]; then
  echo 'Error: run this from the normal Termux home, not root, sudo, or proot.' >&2; exit 1
fi
if ! command -v pkg >/dev/null 2>&1; then
  echo 'Error: Termux pkg was not found. Open a native Termux session.' >&2; exit 1
fi
printf '\n  ✦ NijAI  ·  Termux setup\n\n'
printf 'Repository: %s (branch %s)\n' "$REPO_URL" "$BRANCH"
printf 'This installs or updates Termux packages: python, git and ca-certificates.\n'
printf 'It downloads and runs repository code. Use only if you trust the repository.\n\n'
pkg install -y python git ca-certificates </dev/null
for tool in python3 git; do
  if ! command -v "$tool" >/dev/null 2>&1; then echo "Error: $tool is unavailable after package installation." >&2; exit 1; fi
done
python3 -c 'import sys, ssl; assert sys.version_info >= (3,9), "Python 3.9+ required"' || { echo 'Error: Python or SSL check failed.' >&2; exit 1; }
mkdir -p "$PREFIX/tmp"
STAGE=$(mktemp -d "$PREFIX/tmp/nijai-src.XXXXXXXX")
trap 'rm -rf "$STAGE"' EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
printf '\nDownloading NijAI from GitHub…\n'
if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$STAGE/source" </dev/null; then
  echo 'Error: could not clone the repository. Check network, repository visibility, and main branch.' >&2
  exit 1
fi
if [ ! -f "$STAGE/source/install.sh" ] || [ ! -f "$STAGE/source/nijai.py" ]; then
  echo 'Error: repository is missing install.sh or nijai.py in its root. Upload all project files first.' >&2
  exit 1
fi
bash "$STAGE/source/install.sh" </dev/null
printf '\nSetup files installed and launcher verified.\n'
if [ -t 1 ] && (: </dev/tty) 2>/dev/null; then
  printf 'Starting NijAI first-time setup. Browser login is optional and can be skipped.\n'
  # Do not exec: the EXIT trap needs to remove the temporary checkout afterwards.
  "$HOME/.local/bin/nijai" --setup </dev/tty
else
  printf 'No interactive terminal detected. Run ~/.local/bin/nijai --setup when ready.\n'
fi
