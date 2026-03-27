#!/bin/bash

sudo apt-get update
sudo apt-get install -y tree pgcli psmisc lsof

# add ble sh in the future here
#..
if [ ! -d "$HOME/.local/share/blesh" ]; then
    git clone --recursive https://github.com/akinomyoga/ble.sh.git "$HOME/.local/share/blesh"
    make -C "$HOME/.local/share/blesh" install PREFIX="$HOME/.local"
fi
