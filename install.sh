#!/bin/sh
set -e

# 1. Install Nix only if not already installed
if [ ! -f /nix/var/nix/profiles/default/bin/nix ]; then
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
fi
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 2. Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ajselzilic

# 3. Bootstrap nix-darwin
nix run nix-darwin -- switch --flake ~/.config/nix#macbookpro
