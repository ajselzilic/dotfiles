#!/bin/bash

set -euo pipefail

SSH_DIR="$HOME/.ssh"
REPOS_DIR="$HOME/repos"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
  echo -e "${BLUE}>>> $1${NC}"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

create_ssh_key() {
  local email=$1
  local account=$2
  local ssh_key_path="$SSH_DIR/id_ed25519_$account"

  if [[ ! -f "$ssh_key_path" ]]; then
    print_status "Generating SSH key for $account account..."
    ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_path" -N ""
    print_success "SSH key generated for $account"
  else
    print_status "SSH key already exists for $account"
  fi
}

create_gitconfig() {
  local name=$1
  local email=$2
  local account=$3

  mkdir -p "$REPOS_DIR/$account"

  cat >"$REPOS_DIR/$account/.gitconfig" <<EOF
[user]
    name = $name
    email = $email
[core]
    sshCommand = ssh -i $SSH_DIR/id_ed25519_$account
[url "git@github.com-$account:"]
    insteadOf = git@github.com:
EOF

  print_success "Created .gitconfig for $account"
}

update_ssh_config() {
  local account=$1
  local config_path="$SSH_DIR/config"

  mkdir -p "$SSH_DIR"
  touch "$config_path"

  if ! grep -q "Host github.com-$account" "$config_path"; then
    cat >>"$config_path" <<EOF

# $account GitHub account
Host github.com-$account
    HostName github.com
    User git
    IdentityFile $SSH_DIR/id_ed25519_$account
EOF
    print_success "Updated SSH config for $account"
  else
    print_status "SSH config already exists for $account"
  fi
}

update_global_gitconfig() {
  local accounts=("$@")

  cat >"$HOME/.gitconfig" <<EOF
# Global GitConfig with conditional includes
EOF

  for account in "${accounts[@]}"; do
    cat >>"$HOME/.gitconfig" <<EOF

[includeIf "gitdir:$REPOS_DIR/$account/"]
    path = $REPOS_DIR/$account/.gitconfig
EOF
  done

  print_success "Updated global .gitconfig"
}

main() {
  print_status "Starting Git and SSH setup..."

  mkdir -p "$REPOS_DIR"
  mkdir -p "$SSH_DIR"

  declare -a accounts=("personal")

  print_status "Setting up personal account..."
  read -p "Enter your personal name: " personal_name
  read -p "Enter your personal email: " personal_email

  create_ssh_key "$personal_email" "personal"
  create_gitconfig "$personal_name" "$personal_email" "personal"
  update_ssh_config "personal"

  while true; do
    read -p "Do you want to add another account? (y/n) " yn
    case $yn in
    [Yy]*)
      read -p "Enter account name (e.g., work, client): " account_name
      read -p "Enter your name for this account: " name
      read -p "Enter your email for this account: " email

      accounts+=("$account_name")
      create_ssh_key "$email" "$account_name"
      create_gitconfig "$name" "$email" "$account_name"
      update_ssh_config "$account_name"
      ;;
    [Nn]*)
      break
      ;;
    *)
      echo "Please answer y or n."
      ;;
    esac
  done

  update_global_gitconfig "${accounts[@]}"

  chmod 600 "$SSH_DIR/id_ed25519"*

  print_status "Setup complete!"

  echo -e "\nGenerated SSH public keys (add these to GitHub):"
  for account in "${accounts[@]}"; do
    echo -e "\nFor $account account:"
    cat "$SSH_DIR/id_ed25519_${account}.pub"
  done

  echo -e "\nTo test the setup, run:"
  for account in "${accounts[@]}"; do
    echo "ssh -T github.com-$account"
  done

  echo -e "\nRepository structure created at: $REPOS_DIR"
  echo "You can now clone repositories into:"
  for account in "${accounts[@]}"; do
    echo "$REPOS_DIR/$account/"
  done
}

main
