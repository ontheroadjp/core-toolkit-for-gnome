#!/bin/bash

# -----------------------------------------
# Install
# -----------------------------------------

# -----------------------------------------
# dev
sudo apt update && sudo apt install -y \
    build-essential \
    curl \
    tree \
    git \
    gh \
    tmux \
    fzf \
    bat \
    vim-gtk3 \
    jq \
    yq

# -----------------------------------------
# rofi          launcher
# hyperfile     benchmaker
# rclone        google drive / dropbox
# gocryptfs     encript dir
# - gocryptfs ~/hoge.env ~/hoge   # mount
# - fusermount -u ~/hoge          # unmount
sudo apt install -y \
    rofi \
    hyperfile \
    rclone \
    gocryptfs

# -----------------------------------------
# yt-dlp        downloader
# ffmpeg        encoder
# mpv           music player
sudo apt install -y \
    yt-dlp \
    ffmpeg \
    mpv

# -----------------------------------------
# keyd
# sudo keyd monitor
if ! command -v keyd >/dev/null 2>&1; then
    sudo add-apt-repository ppa:keyd-team/ppa
    sudo apt update
    sudo apt install keyd
    sudo systemctl enable --now keyd
else
    echo "keyd is already installd."
fi

# -----------------------------------------
# mise
MISE_BIN="$(command -v mise 2>/dev/null || true)"
if [[ -z "${MISE_BIN}" ]]; then
    curl https://mise.run | sh
    MISE_BIN="${HOME}/.local/bin/mise"
fi
"${MISE_BIN}" use -g node@24

# -----------------------------------------
# gh
if ! command -v gh >/dev/null 2>&1; then
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh -y
else
    echo "gh is already installd."
fi

# -----------------------------------------
# ghq
if ! command -v ghq >/dev/null 2>&1; then
    echo "Installing ghq ..."
    cd /tmp || exit
    wget https://github.com/x-motemen/ghq/releases/latest/download/ghq_linux_amd64.zip
    unzip ghq_linux_amd64.zip
    sudo mv ghq_linux_amd64/ghq /usr/local/bin
    rm -rf ghq_linux_amd64
else
    echo "ghq is already installd."
fi

# -----------------------------------------
# claude code
if ! command -v claude >/dev/null 2>&1; then
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo "claude code is already installd."
fi

# -----------------------------------------
# codex
if ! command -v codex >/dev/null 2>&1; then
    npm install -g @openai/codex
else
    echo "codex is already installd."
fi

# -----------------------------------------
# chrome
if ! command -v google-chrome >/dev/null 2>&1; then
    echo "Installing Google Chrome ..."
    cd /tmp || exit
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
else
    echo "Google Chrome is already installd."
fi

# -----------------------------------------
# yt-dlp
if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "Installing yt-dlp ..."
    sudo wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp
    sudo chmod a+rx /usr/local/bin/yt-dlp
else
    echo "yt-dlp is already installed and try upgrade to new version if available..."
    sudo yt-dlp -U
fi
