#!/bin/sh
set -e

# 1. Install Nix only if not already installed
if ! command -v nix > /dev/null 2>&1; then
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "Nix already installed, skipping..."
fi

# 2. Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ajselzilic

# 3. Bootstrap nix-darwin
nix run nix-darwin -- switch --flake ~/.config/nix#macbookpro
