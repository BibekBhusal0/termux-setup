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

clone() {
  local item_name="$1"
  local base_path="$2"

  # Full URL
  if [[ "$item_name" =~ ^https?:// ]]; then
    repo_url="$item_name"
    item_dir="${base_path}/$(basename "$repo_url" .git)"
  # Username/reponame format
  elif [[ "$item_name" =~ / ]]; then
    repo_url="https://github.com/${item_name}.git"
    item_dir="${base_path}/$(basename "$repo_url" .git)"
  # Defaults to zsh-users owner
  else
    repo_url="https://github.com/bibekbhusal0/${item_name}.git"
    item_dir="${base_path}/$(basename "$repo_url" .git)"
  fi

  # Check if the item directory already exists
  if [ -d "$item_dir" ]; then
    echo "$item_name directory $item_dir already exists. Skipping..."
  else
    git clone "$repo_url" "$item_dir"
  fi
}

mkdir -p ~/Code 
clone omarchy-overrides ~/Code/omarchy-overrides
clone basecamp/omarchy ~/Code/omarchy
mkdir ~/.config
clone neovim-kickstart-config-config ~/.config/nvim
mkdir -p ~/Code/nvim-plugins
clone bufstack.nvim ~/Code/nvim-plugins/bufstack.nvim
clone nvim-shadcn ~/Code/nvim-plugins/nvim-shadcn
clone nvim-git-utils ~/Code/nvim-plugins/nvim-git-utils

ln -s ~/Code/nvim-plugins/
