#!/data/data/com.termux/files/usr/bin/bash

# Installing required packages
packages=(
  eza
  fd
  fzf
  git
  lua-language-server
  neovim
  nodejs
  ripgrep
  starship
  stylua
  tmux
  zoxide
)

for pkg in "${packages[@]}"; do
  if pkg list-installed 2>/dev/null | grep -q "^$pkg/"; then
    echo "$pkg already installed, skipping..."
  else
    echo "Installing $pkg"
    pkg install -y "$pkg"
  fi
done



# cloning essential reposoteries.
git clone https://github.com/basecamp/omarchy ~/omarchy --depth=10
