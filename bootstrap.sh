#!/bin/sh
set -e

# 1. Install Nix
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# Source Nix so it's available immediately
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 2. Apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ajselzilic

# 3. Switch nix-darwin
nix run nix-darwin -- switch --flake ~/.config/nix#macbookpro
