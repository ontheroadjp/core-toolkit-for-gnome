#!/bin/bash

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PASS=0
FAIL=0

pass() { echo "PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL  $1"; FAIL=$((FAIL + 1)); }

INSTALL_SCRIPTS=(
    "scripts/core-tools/install.sh"
    "applications/keyd/install.sh"
    "applications/alacritty/install.sh"
    "applications/mpv-player/install.sh"
    "applications/yt-dlp/install.sh"
    "applications/espanso/install.sh"
    "applications/chrome/install.sh"
    "applications/dolphin/install.sh"
    "install-all.sh"
)

# -----------------------------------------
echo "--- Test 1: syntax check (shellcheck or bash -n) ---"

if command -v shellcheck >/dev/null 2>&1; then
    CHECKER="shellcheck"
else
    CHECKER="bash_n"
fi

for script in "${INSTALL_SCRIPTS[@]}"; do
    f="${REPO_DIR}/${script}"
    if [ ! -f "$f" ]; then
        fail "not found: ${script}"
        continue
    fi
    if [ "$CHECKER" = "shellcheck" ]; then
        if shellcheck "$f" 2>/dev/null; then
            pass "shellcheck: ${script}"
        else
            fail "shellcheck: ${script}"
        fi
    else
        if bash -n "$f" 2>/dev/null; then
            pass "bash -n: ${script}"
        else
            fail "bash -n: ${script}"
        fi
    fi
done

# -----------------------------------------
echo ""
echo "--- Test 2: referenced files exist ---"

check_file() {
    local label="$1" path="$2"
    [ -f "$path" ] && pass "$label" || fail "$label (not found: $path)"
}

check_file "mpv-player.py exists"         "${REPO_DIR}/applications/mpv-player/mpv-player.py"
check_file "espanso-toggle exists"        "${REPO_DIR}/applications/espanso/espanso-toggle"
check_file "google-chrome-cdp exists"     "${REPO_DIR}/applications/chrome/google-chrome-cdp"
check_file "google-chrome-cdp.desktop"   "${REPO_DIR}/applications/chrome/google-chrome-cdp.desktop"
check_file "keyd/default.conf exists"    "${REPO_DIR}/applications/keyd/default.conf"
check_file "keyd/fep-toggle.sh exists"   "${REPO_DIR}/applications/keyd/fep-toggle.sh"
check_file "alacritty.toml exists"       "${REPO_DIR}/applications/alacritty/alacritty.toml"
check_file "yt-dlp config exists"        "${REPO_DIR}/applications/yt-dlp/config"
check_file "fep-switcher extension.js"   "${REPO_DIR}/scripts/fep-switcher/extension.js"
check_file "app-switch extension.js"     "${REPO_DIR}/scripts/app-switch-us-input/extension.js"
check_file "switch-input-to-us exists"   "${REPO_DIR}/scripts/tmux-switch-us-input/switch-input-to-us"

# -----------------------------------------
echo ""
echo "--- Test 3: install-all.sh calls all per-app scripts ---"

EXPECTED_CALLS=(
    "scripts/core-tools/install.sh"
    "applications/keyd/install.sh"
    "applications/alacritty/install.sh"
    "applications/mpv-player/install.sh"
    "applications/yt-dlp/install.sh"
    "applications/espanso/install.sh"
    "applications/chrome/install.sh"
    "applications/dolphin/install.sh"
)

ROOT_INSTALL="${REPO_DIR}/install-all.sh"
for expected in "${EXPECTED_CALLS[@]}"; do
    if grep -qF "${expected}" "$ROOT_INSTALL"; then
        pass "install-all.sh calls: ${expected}"
    else
        fail "install-all.sh missing call: ${expected}"
    fi
done

# -----------------------------------------
echo ""
echo "--- Test 4: tool coverage (old t480s-apps-install.sh → new scripts) ---"

NEW_SCRIPTS_CONTENT=$(cat \
    "${REPO_DIR}/scripts/core-tools/install.sh" \
    "${REPO_DIR}/applications/keyd/install.sh" \
    "${REPO_DIR}/applications/mpv-player/install.sh" \
    "${REPO_DIR}/applications/yt-dlp/install.sh" \
    "${REPO_DIR}/applications/espanso/install.sh" \
    "${REPO_DIR}/applications/chrome/install.sh")

TOOLS=(
    build-essential tmux fzf bat vim-gtk3 jq
    hyperfine rclone gocryptfs htop ncdu nethogs
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    groupadd usermod keyd mise ghq claude codex
    google-chrome yt-dlp espanso ffmpeg mpv
    gnome-shell-extension-manager
)

for tool in "${TOOLS[@]}"; do
    if echo "${NEW_SCRIPTS_CONTENT}" | grep -q "${tool}"; then
        pass "covered: ${tool}"
    else
        fail "not covered: ${tool}"
    fi
done

# -----------------------------------------
echo ""
echo "--- Test 5: t480s-apps-install.sh is removed ---"

OLD_SCRIPT="${REPO_DIR}/t480s/t480s-apps-install.sh"
if [ ! -f "$OLD_SCRIPT" ]; then
    pass "t480s-apps-install.sh removed"
else
    fail "t480s-apps-install.sh still exists"
fi

# -----------------------------------------
echo ""
echo "--- Test 6: config directory links use ln -sfn ---"

# On re-run, `ln -sf DIR LINK` dereferences an existing LINK that points to a
# directory and creates the new link *inside* the repo (e.g.
# applications/alacritty/alacritty). -n replaces the link itself.
CONFIG_LINK_SCRIPTS=(
    "applications/alacritty/install.sh"
    "applications/espanso/install.sh"
    "applications/yt-dlp/install.sh"
    "applications/mpv-player/install.sh"
)

for script in "${CONFIG_LINK_SCRIPTS[@]}"; do
    f="${REPO_DIR}/${script}"
    # shellcheck disable=SC2016  # matching literal ${SCRIPT_DIR} in the script source
    if grep -qE '^ln -sf "\$\{SCRIPT_DIR\}" "\$\{CONFIG_DIR\}/' "$f"; then
        fail "config dir link without -n: ${script}"
    else
        pass "config dir link uses -sfn: ${script}"
    fi
done

# alacritty's installer only touches $HOME, so it is safe to run for real.
TMP_HOME="$(mktemp -d)"
NESTED_LINK="${REPO_DIR}/applications/alacritty/alacritty"
if [ -e "$NESTED_LINK" ] || [ -L "$NESTED_LINK" ]; then
    fail "alacritty: nested link already exists before test (${NESTED_LINK})"
else
    HOME="$TMP_HOME" bash "${REPO_DIR}/applications/alacritty/install.sh" >/dev/null
    HOME="$TMP_HOME" bash "${REPO_DIR}/applications/alacritty/install.sh" >/dev/null
    if [ -e "$NESTED_LINK" ] || [ -L "$NESTED_LINK" ]; then
        fail "alacritty: re-run created nested link in repo"
        rm -f "$NESTED_LINK"
    else
        pass "alacritty: re-run creates no nested link in repo"
    fi
    if [ "$(readlink "${TMP_HOME}/.config/alacritty")" = "${REPO_DIR}/applications/alacritty" ]; then
        pass "alacritty: ~/.config/alacritty points to repo dir"
    else
        fail "alacritty: ~/.config/alacritty does not point to repo dir"
    fi
fi
rm -rf "$TMP_HOME"

# -----------------------------------------
echo ""
echo "--- Test 7: per-step results and continuation ---"

fixture="$(mktemp -d)"
fixture_home="$fixture/home"
mkdir -p "$fixture/repo/scripts" "$fixture/repo/applications" "$fixture/bin" \
    "$fixture_home/.local/bin" "$fixture_home/.local/share/gnome-shell/extensions"
cp "$ROOT_INSTALL" "$fixture/repo/install-all.sh"
for script in "${EXPECTED_CALLS[@]}"; do
    mkdir -p "$fixture/repo/$(dirname "$script")"
    cat > "$fixture/repo/$script" <<'EOF'
#!/bin/bash
printf 'ran: %s\n' "${BASH_SOURCE[0]%/install.sh}"
[[ "${BASH_SOURCE[0]}" != *"/${FAIL_STEP:-never}/install.sh" ]]
EOF
    chmod +x "$fixture/repo/$script"
done
cat > "$fixture/bin/gnome-extensions" <<'EOF'
#!/bin/bash
[[ "$*" != *"${FAIL_EXTENSION:-never}"* ]]
EOF
chmod +x "$fixture/bin/gnome-extensions"

if HOME="$fixture/home" PATH="$fixture/bin:$PATH" bash "$fixture/repo/install-all.sh" > "$fixture/success" 2>&1 \
    && grep -q '^SUCCESS: dolphin$' "$fixture/success" \
    && grep -q '^SUCCESS: tmux-switch-us-input$' "$fixture/success" \
    && awk '/^SUCCESS: dolphin$/ { found=1; if (previous !~ /ran: .*\/applications\/dolphin$/) exit 1 } { previous=$0 } END { if (!found) exit 1 }' "$fixture/success"; then
    pass "all steps succeed"
else
    fail "all steps succeed"
fi

if HOME="$fixture/home" PATH="$fixture/bin:$PATH" FAIL_STEP=dolphin FAIL_EXTENSION=fep-switcher@local \
    bash "$fixture/repo/install-all.sh" > "$fixture/failure" 2>&1; then
    fail "failures return nonzero"
elif grep -q '^FAILED: dolphin$' "$fixture/failure" \
    && grep -q '^FAILED: fep-switcher$' "$fixture/failure" \
    && grep -q '^SUCCESS: app-switch-us-input$' "$fixture/failure" \
    && grep -q '^SUCCESS: tmux-switch-us-input$' "$fixture/failure" \
    && grep -q 'Manual step: ~/.tmux.conf' "$fixture/failure"; then
    pass "failures are reported and later steps run"
else
    fail "failures are reported and later steps run"
fi

mkdir -p "$fixture/conflict/.local/share/gnome-shell/extensions/fep-switcher@local"
printf 'keep\n' > "$fixture/conflict/.local/share/gnome-shell/extensions/fep-switcher@local/marker"
if HOME="$fixture/conflict" PATH="$fixture/bin:$PATH" bash "$fixture/repo/install-all.sh" > "$fixture/conflict-output" 2>&1; then
    fail "existing extension conflict returns nonzero"
elif [ -f "$fixture/conflict/.local/share/gnome-shell/extensions/fep-switcher@local/marker" ] \
    && grep -q '^FAILED: fep-switcher$' "$fixture/conflict-output" \
    && grep -q '^SUCCESS: tmux-switch-us-input$' "$fixture/conflict-output"; then
    pass "existing extension is preserved and later steps run"
else
    fail "existing extension is preserved and later steps run"
fi

if HOME="$fixture_home" PATH="$fixture/bin:$PATH" bash "$fixture/repo/install-all.sh" > "$fixture/repeat" 2>&1 \
    && grep -q '^SUCCESS: fep-switcher$' "$fixture/repeat"; then
    pass "managed extensions can be installed again"
else
    fail "managed extensions can be installed again"
fi
rm -rf "$fixture"

# -----------------------------------------
echo ""
echo "--- Test 10: keyd configuration protection ---"
fixture="$(mktemp -d)"
mkdir -p "$fixture/bin" "$fixture/keyd-source"
sed -e "s|/etc/keyd|$fixture/keyd-target|g" \
    -e "s|/usr/local/bin/fep-toggle|$fixture/bin/fep-toggle|g" \
    "$REPO_DIR/applications/keyd/install.sh" > "$fixture/keyd-source/install.sh"
cp "$REPO_DIR/applications/keyd/fep-toggle.sh" "$fixture/keyd-source/fep-toggle.sh"
ln -s /bin/true "$fixture/bin/keyd"
cat > "$fixture/bin/sudo" <<'EOF'
#!/bin/bash
exec "$@"
EOF
chmod +x "$fixture/bin/sudo"
mkdir -p "$fixture/keyd-target"
printf 'keep\n' > "$fixture/keyd-target/marker"
if PATH="$fixture/bin:$PATH" bash "$fixture/keyd-source/install.sh" > "$fixture/conflict-output" 2>&1; then
    fail "keyd rejects existing configuration"
elif [ -f "$fixture/keyd-target/marker" ]; then
    pass "keyd preserves existing configuration"
else
    fail "keyd preserves existing configuration"
fi
mv "$fixture/keyd-target" "$fixture/saved"
if PATH="$fixture/bin:$PATH" bash "$fixture/keyd-source/install.sh" > "$fixture/install-output" 2>&1 \
    && PATH="$fixture/bin:$PATH" bash "$fixture/keyd-source/install.sh" > "$fixture/repeat-output" 2>&1 \
    && [ "$(readlink "$fixture/keyd-target")" = "$fixture/keyd-source" ]; then
    pass "keyd succeeds on install and rerun"
else
    fail "keyd succeeds on install and rerun"
fi
rm -rf "$fixture"

# -----------------------------------------
echo ""
echo "--- Test 8: configuration conflicts and reruns ---"

fixture="$(mktemp -d)"
mkdir -p "$fixture/bin" "$fixture/repo/applications"
cat > "$fixture/bin/sudo" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$fixture/bin/sudo"
for name in alacritty mpv-player yt-dlp espanso; do
    cp -R "$REPO_DIR/applications/$name" "$fixture/repo/applications/$name"
done
ln -s /bin/true "$fixture/bin/yt-dlp"
ln -s /bin/true "$fixture/bin/espanso"
for entry in alacritty:alacritty mpv-player:mpv yt-dlp:yt-dlp espanso:espanso; do
    name="${entry%%:*}"
    config="${entry#*:}"
    test_home="$fixture/user-$name"
    mkdir -p "$test_home/.config/$config"
    printf 'keep\n' > "$test_home/.config/$config/marker"
    if HOME="$test_home" PATH="$fixture/bin:$PATH" bash "$fixture/repo/applications/$name/install.sh" >/dev/null 2>&1; then
        fail "$name rejects existing configuration"
    elif [ -f "$test_home/.config/$config/marker" ]; then
        pass "$name preserves existing configuration"
    else
        fail "$name preserves existing configuration"
    fi
    mv "$test_home/.config/$config" "$test_home/saved"
    if HOME="$test_home" PATH="$fixture/bin:$PATH" bash "$fixture/repo/applications/$name/install.sh" >/dev/null 2>&1 \
        && HOME="$test_home" PATH="$fixture/bin:$PATH" bash "$fixture/repo/applications/$name/install.sh" >/dev/null 2>&1 \
        && [ "$(readlink "$test_home/.config/$config")" = "$fixture/repo/applications/$name" ]; then
        pass "$name succeeds on install and rerun"
    else
        fail "$name succeeds on install and rerun"
    fi
done
rm -rf "$fixture"

# -----------------------------------------
echo ""
echo "--- Test 9: core-tools failure propagation ---"
fixture="$(mktemp -d)"
mkdir -p "$fixture/bin"
cat > "$fixture/bin/sudo" <<'EOF'
#!/bin/bash
if [[ "$1" == apt && "$2" == update && "${FAIL_APT:-0}" == 1 ]]; then exit 1; fi
if [[ "$1" == tee ]]; then cat >/dev/null; fi
exit 0
EOF
cat > "$fixture/bin/curl" <<'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "$fixture/bin/sudo" "$fixture/bin/curl"
if FAIL_APT=1 PATH="$fixture/bin:$PATH" bash "$REPO_DIR/scripts/core-tools/install.sh" > "$fixture/apt-output" 2>&1; then
    fail "apt update failure propagates"
elif grep -q '\[1/10\] Done' "$fixture/apt-output"; then
    fail "apt update failure stops the first step"
else
    pass "apt update failure propagates"
fi
if USER=test PATH="$fixture/bin:$PATH" bash "$REPO_DIR/scripts/core-tools/install.sh" > "$fixture/curl-output" 2>&1; then
    fail "download failure propagates through pipeline"
elif grep -q '\[5/10\] Done' "$fixture/curl-output"; then
    fail "download failure stops the Docker step"
else
    pass "download failure propagates through pipeline"
fi
rm -rf "$fixture"

# -----------------------------------------
echo ""
echo "=============================="
echo "Results: ${PASS} passed, ${FAIL} failed"
echo "=============================="
[ "$FAIL" -eq 0 ]
