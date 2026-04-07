#!/bin/bash

# 1. Get the absolute path of the dotfiles directory
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 2. FORCE the symlink using the absolute path
# This ensures it points to /home/codespace/dotfiles/.bashrc
ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"

# 3. Fix permissions just in case
chmod 644 "$DOTFILES_DIR/.bashrc"

# 4. Install tools
sudo apt-get update
sudo apt-get install -y tree pgcli psmisc lsof

# 5. Ble.sh install
if [ ! -d "$HOME/.local/share/blesh" ]; then
    git clone --recursive https://github.com/akinomyoga/ble.sh.git "$HOME/.local/share/blesh"
    sudo apt-get install -y make
    make -C "$HOME/.local/share/blesh" install PREFIX="$HOME/.local"
fi

# 6. Install Go Debugger (Delve)
if ! command -v dlv &> /dev/null; then
    echo "Installing Delve debugger..."
    # Ensure Go is in the path for the installer
    export PATH=$PATH:/usr/local/go/bin
    go install github.com/go-delve/delve/cmd/dlv@latest
fi