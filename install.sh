#!/bin/bash

# .GITCONFIG SETUP

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${1:-$SCRIPT_DIR}" # Default to script directory if no argument provided
GITCONFIG_SOURCE="$DOTFILES_DIR/.gitconfig"
GITCONFIG_DEST="$HOME/.gitconfig"

# Copy .gitconfig from the dotfiles directory to the home directory
if [ -f "$GITCONFIG_SOURCE" ]; then
    cp "$GITCONFIG_SOURCE" "$GITCONFIG_DEST"
    echo ".gitconfig copied to $HOME"
else
    echo "Error: .gitconfig not found in $DOTFILES_DIR"
    exit 1
fi

# Check for a GPG signing key
GPG_KEY=$(gpg --list-secret-keys --keyid-format LONG | grep 'sec' | awk '{print $2}' | cut -d '/' -f 2)

if [ -n "$GPG_KEY" ]; then
    echo "Found GPG key: $GPG_KEY"
    # Add the GPG key to the git config
    git config --global user.signingkey "$GPG_KEY"
    echo "Signing key added to global git config."
else
    echo "No GPG key found."
    echo "To sign Git commits, please create a GPG key using the following command:"
    echo "    gpg --full-generate-key"
    echo "Then, rerun this script."
fi
