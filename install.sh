#!/bin/bash

# 1. FORCE the symlink (This is the fix)
# This points the system .bashrc to YOUR version in the repo
ln -sf ~/dotfiles/.bashrc ~/.bashrc

# 2. Install your required tools
sudo apt-get update
sudo apt-get install -y tree pgcli psmisc lsof

# 3. Optional: Install ble.sh for syntax highlighting
if [ ! -d "$HOME/.local/share/blesh" ]; then
    git clone --recursive https://github.com/akinomyoga/ble.sh.git "$HOME/.local/share/blesh"
    # Note: We use 'make' but it might need to be installed too
    sudo apt-get install -y make
    make -C "$HOME/.local/share/blesh" install PREFIX="$HOME/.local"
fi
