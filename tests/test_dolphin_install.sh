#!/bin/bash
set -euo pipefail

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
export HOME="$TEST_DIR/home"
export XDG_DATA_HOME="$HOME/data"
export XDG_STATE_HOME="$HOME/state"
mkdir -p "$HOME" "$TEST_DIR/bin"
cat > "$TEST_DIR/bin/dpkg-query" <<'STUB'
#!/bin/sh
printf 'install ok installed'
STUB
chmod +x "$TEST_DIR/bin/dpkg-query"
export PATH="$TEST_DIR/bin:$PATH"
installer="$REPO_DIR/applications/dolphin/install.sh"
target="$XDG_DATA_HOME/applications/org.kde.dolphin.desktop"
bash "$installer"
grep -q '^Exec=env QT_QPA_PLATFORM=xcb dolphin %u$' "$target"
bash "$installer"
printf '\n# user edit\n' >> "$target"
cp "$target" "$TEST_DIR/expected"
if bash "$installer" > "$TEST_DIR/output" 2>&1; then
    echo 'Expected edited entry to be rejected' >&2
    exit 1
fi
grep -q 'user-edited' "$TEST_DIR/output"
cmp "$target" "$TEST_DIR/expected"
echo 'Dolphin installer tests passed'
