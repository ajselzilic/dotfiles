#!/bin/sh
set -e

# 1. Install Nix only if not already installed
if [ ! -f /nix/var/nix/profiles/default/bin/nix ]; then
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
fi

# 2. Ensure Nix daemon is running
sleep 3
if ! /nix/var/nix/profiles/default/bin/nix store ping > /dev/null 2>&1; then
  echo "Nix daemon not responding, trying to start..."
  sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.nix-daemon.plist || true
  sleep 5
fi

source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 3. Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ajselzilic

# 4. Bootstrap nix-darwin
sudo HOME=$HOME nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/.config/nix#macbookpro
