#!/bin/sh
set -e

# 1. Install Nix
curl -L https://nixos.org/nix/install | sh -s -- --daemon
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 2. Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ajselzilic

# 3. Bootstrap nix-darwin (installs it + applies your flake)
nix run nix-darwin -- switch --flake ~/.config/nix#macbookpro
