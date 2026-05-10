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
  termux-api
  xz-utils
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

# Cloning required projects
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

git config --global credential.helper store
git config --global user.name "Bibek Bhusal"
git config --global user.email "bibekbhusal04@gmail.com"

copy() {
  local src="$1"
  local dest="$2"
  if [ -f "$dest" ]; then
    echo "File $dest already exists. Skipping copy."
  else
    cp "$src" "$dest"
    echo "Copied $src to $dest"
  fi
}

copy ~/Code/omarchy/config/starship.toml ~/.config/starship.toml
mkdir -p ~/.config/tmux
cat > ~/.config/tmux/tmux.conf << EOF
source ~/Code/omarchy/config/tmux/tmux.conf
source ~/Code/omarchy-overrides/overwrite/tmux.conf
EOF

cat >> ~/.termux/termux.properties << EOF
shortcut.create-session = ctrl + t
shortcut.previous-session = ctrl + (
shortcut.next-session = ctrl + )
shortcut.close-session = ctrl + q
shortcut.rename-session = ctrl + \`
extra-keys = []
fullscreen = true
EOF

curl -fLo JetBrainsMono.tar.xz "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
tar -xf JetBrainsMono.tar.xz "JetBrainsMonoNerdFont-Regular.ttf"
mv JetBrainsMonoNerdFont-Regular.ttf ~/.termux/font.ttf
rm JetBrainsMono.tar.xz

touch ~/.hushlogin
termux-reload-settings
clear
