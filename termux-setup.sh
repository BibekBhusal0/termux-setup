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
  zsh
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
    echo "File $dest already exists. Skipping copy ..."
  else
    cp "$src" "$dest"
    echo "Copied $src to $dest"
  fi
}

write_to_file() {
  local file="$1"
  local pattern="$2"
  if grep -qF "$pattern" "$file" 2>/dev/null; then
    echo "Content already written to $file. Skipping ..."
  else
    cat >> "$file"
    echo "Written in: $file"
  fi
}

copy ~/Code/omarchy/config/starship.toml ~/.config/starship.toml
copy ~/Code/omarchy/config/git/config ~/.config/git/config

mkdir -p ~/.config/tmux

write_to_file ~/.config/tmux/tmux.conf << EOF
source ~/Code/omarchy/config/tmux/tmux.conf
source ~/Code/omarchy-overrides/overwrite/tmux.conf
EOF

# Set zsh as default shell if not already
if [[ "$SHELL" != */zsh ]]; then
  echo "Setting zsh as default shell..."
  chsh -s zsh
fi

mkdir -p ~/.local/share/omarchy/default/
ln -s ~/Code/omarchy/default/bash/ ~/.local/share/omarchy/default/bash

write_to_file ~/.zshrc << EOF
source ~/Code/omarchy-overrides/zsh/rc.sh
EOF

~/Code/omarchy-overrides/install/zsh-plugins.sh

write_to_file ~/.termux/termux.properties "shortcut.create-session" << EOF
shortcut.create-session = ctrl + t
shortcut.previous-session = ctrl + (
shortcut.next-session = ctrl + )
shortcut.close-session = ctrl + q
shortcut.rename-session = ctrl + \`
extra-keys = []
fullscreen = true
EOF

if [ -f ~/.termux/font.ttf ]; then
  echo "JetBrains Mono font already installed, skipping..."
else
  echo "Installing JetBrains Mono font..."
  curl -fLo JetBrainsMono.tar.xz "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
  tar -xf JetBrainsMono.tar.xz "JetBrainsMonoNerdFont-Regular.ttf"
  mv JetBrainsMonoNerdFont-Regular.ttf ~/.termux/font.ttf
  rm JetBrainsMono.tar.xz
fi

touch ~/.hushlogin

install_npm_global() {
  local pkg="$1"
  local binary="${2:-$pkg}"
  if command -v "$binary" &>/dev/null; then
    echo "$pkg already installed globally, skipping..."
  else
    echo "Installing $pkg globally..."
    npm install -g "$pkg"
  fi
}

# Installing global npm packages
install_npm_global devmoji
install_npm_global @google/gemini-cli gemini

termux-reload-settings
