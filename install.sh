#!/usr/bin/env bash
set -eu
umask 077
SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/nijai"
BINDIR="$HOME/.local/bin"
if ! command -v python3 >/dev/null 2>&1; then
  echo 'Error: python3 is missing. Install Python 3.9+ using apt (Ubuntu) or pkg (Termux).' >&2; exit 1
fi
PYTHON=$(command -v python3)
if ! "$PYTHON" -c 'import sys, ssl; assert sys.version_info >= (3, 9), "Python 3.9+ required"' ; then
  echo 'Error: Python 3.9+ with working SSL is required.' >&2; exit 1
fi
PLATFORM=$("$PYTHON" -c 'import sys; print(sys.platform)')
if [ -r /etc/os-release ] && grep -Eqi '^ID=(ubuntu|debian)$' /etc/os-release && [ "$PLATFORM" != linux ]; then
  echo 'Error: Ubuntu/Debian is using non-Linux Python. Install python3 with apt and remove Termux from PATH.' >&2; exit 1
fi
[ -f "$SOURCE_DIR/nijai.py" ] || { echo 'Error: nijai.py is missing. Clone the whole repository first.' >&2; exit 1; }
mkdir -p "$DEST" "$BINDIR"
cp "$SOURCE_DIR/nijai.py" "$DEST/nijai.py.tmp"
"$PYTHON" "$DEST/nijai.py.tmp" --version >/dev/null
mv "$DEST/nijai.py.tmp" "$DEST/nijai.py"
TMP="$BINDIR/.nijai.tmp.$$"
trap 'rm -f "$TMP"' EXIT
BASH_BIN=$(command -v bash)
printf '#!%s\nexec %q %q "$@"\n' "$BASH_BIN" "$PYTHON" "$DEST/nijai.py" > "$TMP"
chmod 755 "$TMP"
mv "$TMP" "$BINDIR/nijai"
# Verify the real launcher before claiming success.
"$BINDIR/nijai" --version
RC="$HOME/.bashrc"
LINE='case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac'
if ! grep -Fqx "$LINE" "$RC" 2>/dev/null; then
  printf '\n# NijAI command path\n%s\n' "$LINE" >> "$RC"
fi
printf '\nInstalled. In your current shell run:\n  export PATH="$HOME/.local/bin:$PATH"\n  nijai\n\nFor a diagnostic check: nijai --doctor\n'
