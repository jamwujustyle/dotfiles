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
sudo apt-get install -y tree pgcli psmisc lsof curl unzip

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

# 7. Install Protoc Engine (v34.1) & Go Plugins
if ! command -v protoc &> /dev/null || ! protoc --version | grep -q "34."; then
    echo "Installing Protoc v34.1..."

    # Architecture check for portability
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ]; then
        PROTOC_ARCH="aarch_64"
    else
        PROTOC_ARCH="x86_64"
    fi

    PROTOC_VERSION="34.1"
    PROTOC_ZIP="protoc-${PROTOC_VERSION}-linux-${PROTOC_ARCH}.zip"

    curl -OL "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/${PROTOC_ZIP}"

    # Extract binary and includes
    sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
    sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'

    rm -f $PROTOC_ZIP
    sudo chmod +x /usr/local/bin/protoc
fi

echo "Installing Protobuf Go plugins..."
# Ensure Go is in the path for the installer
export PATH=$PATH:/usr/local/go/bin
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

if ! command -v evans &> /dev/null; then
    echo "installing evans gRPC CLI..."
    export PATH=$PATH:/usr/local/go/bin:$(go env GOPATH)/bin
    go install github.com/ktr0731/evans@latest
fi