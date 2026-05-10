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
  local target_dir="$2"
  local shallow="$3"

  # Determine repo URL
  if [[ "$item_name" =~ ^https?:// ]]; then
    repo_url="$item_name"
  elif [[ "$item_name" =~ / ]]; then
    repo_url="https://github.com/${item_name}.git"
  else
    repo_url="https://github.com/bibekbhusal0/${item_name}.git"
  fi

  # Check if the target directory already exists
  if [ -d "$target_dir" ]; then
    echo "$item_name directory $target_dir already exists. Skipping..."
  else
    if [ "$shallow" = "true" ]; then
      git clone --depth 10 "$repo_url" "$target_dir"
    else
      git clone "$repo_url" "$target_dir"
    fi
  fi
}

mkdir -p ~/Code 
clone omarchy-overrides ~/Code/omarchy-overrides
clone basecamp/omarchy ~/Code/omarchy true
mkdir ~/.config
clone neovim-kickstart-config-config ~/.config/nvim
mkdir -p ~/Code/nvim-plugins
clone bufstack.nvim ~/Code/nvim-plugins/bufstack.nvim
clone nvim-shadcn ~/Code/nvim-plugins/nvim-shadcn
clone nvim-git-utils ~/Code/nvim-plugins/nvim-git-utils
