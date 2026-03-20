#!/bin/sh
set -e

# 1. Install Nix only if not already installed
if [ ! -f /nix/var/nix/profiles/default/bin/nix ]; then
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
fi

# 2. Ensure Nix daemon is running
if ! /nix/var/nix/profiles/default/bin/nix store ping > /dev/null 2>&1; then
  sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
  sleep 3
fi

source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 3. Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ajselzilic

# 4. Bootstrap nix-darwin
sudo HOME=$HOME nix run nix-darwin -- switch --flake ~/.config/nix#macbookpro
