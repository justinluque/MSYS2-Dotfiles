#!/bin/bash

# GENERAL SETUP

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${1:-$SCRIPT_DIR}" # Default to script directory if no argument provided
packages_file="packages.${MSYSTEM,,}.txt"

# INSTALL ENVIRONMENT PACKAGES

# Check if the file exists
if [ -f "$packages_file" ]; then
  echo "Using packages file: $packages_file"
  # Process the packages file (e.g., install packages)
else
  echo "Error: No packages file found for environment '$MSYSTEM'."
  echo "Expected file: $packages_file"
  exit 1
fi

# Install packages using pacman
echo "Installing packages listed in $packages_file..."
if pacman -S --needed --noconfirm - <"$packages_file"; then
  echo "All packages installed successfully!"
else
  echo "Error: Some packages could not be installed."
  exit 1
fi

# Function to check if key is loaded into ssh-agent
is_key_loaded() {
  ssh-add -l 2>/dev/null | grep -q "$KEY_PATH"
}
$()
# .BASHRC SETUP

# Define the source and destination for .bashrc
BASHRC_SOURCE="$DOTFILES_DIR/.bashrc"
BASHRC_DEST="$HOME/.bashrc"

# Copy .bashrc from the dotfiles directory to the home directory
if [ -f "$BASHRC_SOURCE" ]; then
  cp "$BASHRC_SOURCE" "$BASHRC_DEST"
  echo ".bashrc copied to $HOME"
else
  echo "Error: .bashrc not found in $DOTFILES_DIR"
  exit 1
fi

# Reload .bashrc to apply changes immediately
if [ -f "$BASHRC_DEST" ]; then
  source "$BASHRC_DEST"
  echo ".bashrc reloaded"
else
  echo "Error: Failed to reload .bashrc"
fi

# .GITCONFIG SETUP

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

# GPG SETUP

# Check for a GPG signing key
GPG_KEY=$(gpg --list-secret-keys --keyid-format LONG | grep 'sec' | awk '{print $2}' | cut -d '/' -f 2)

if [ -n "$GPG_KEY" ]; then
  echo "Found GPG key: $GPG_KEY"
  # Add the GPG key to the git config
else
  echo "No GPG key found. Initiating GPG key generation..."
  gpg --full-generate-key

  # Check again after key generation
  GPG_KEY=$(gpg --list-secret-keys --keyid-format LONG | grep 'sec' | awk '{print $2}' | cut -d '/' -f 2)
  if [ -n "$GPG_KEY" ]; then
    echo "New GPG key created: $GPG_KEY"
  else
    echo "Key generation failed or was canceled. Please try again."
  fi
fi

# LINK GPG TO GIT

git config --global user.signingkey "$GPG_KEY"
echo "Signing key added to global git config."

# SSH SETUP

# Define the file path for the SSH key
KEY_PATH="$HOME/.ssh/id_ed25519"

# Check if the SSH key already exists
if [ -f "$KEY_PATH" ]; then
  echo "SSH key already exists at $KEY_PATH"
else
  # Ask for the user's email address
  read -p "Enter your email for the SSH key: " email

  # Generate the SSH key with Ed25519 algorithm
  echo "Generating SSH key with Ed25519 algorithm..."
  ssh-keygen -t ed25519 -C "$email" -f "$KEY_PATH"

  echo "SSH key generated successfully at $KEY_PATH"
  echo "Public key: $KEY_PATH.pub"
fi

