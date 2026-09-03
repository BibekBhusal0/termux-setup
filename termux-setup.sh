#!/data/data/com.termux/files/usr/bin/bash

is_pkg_installed() {
  pkg list-installed "$1" 2>/dev/null | grep -q "^$1/"
}

install_pkg() {
  if is_pkg_installed "$1"; then
    echo "$1 already installed, skipping..."
  else
    echo "Installing $1..."
    pkg install -y "$1"
  fi
}

remove_pkg() {
  if is_pkg_installed "$1"; then
    echo "Removing $1..."
    pkg uninstall -y "$1"
  else
    echo "$1 not installed, skipping removal..."
  fi
}

echo "Removing unnecessary pre-installed packages..."
for bloat in nano ed inetutils command-not-found; do
  remove_pkg "$bloat"
done

# Installing required packages
packages=(
  bat
  eza
  fd
  fzf
  gh
  git
  lua-language-server
  neovim
  nodejs
  ripgrep
  ruby
  starship
  stylua
  termux-api
  tmux
  zoxide
  zsh
)

for pkg in "${packages[@]}"; do
  install_pkg "$pkg"
done

# Cloning required projects
if [ ! -d "$HOME/Code/omarchy-overrides" ]; then
  git clone https://github.com/bibekbhusal0/omarchy-overrides.git ~/Code/omarchy-overrides
fi

# Source utility functions
source ~/Code/omarchy-overrides/utils/clone.sh
source ~/Code/omarchy-overrides/utils/write-to-file.sh
source ~/Code/omarchy-overrides/utils/symlink.sh
source ~/Code/omarchy-overrides/install/my-bins.sh

clone basecamp/omarchy ~/Code/omarchy --depth 10
clone neovim-kickstart-config-config ~/.config/nvim
clone bufstack.nvim ~/Code/nvim-plugins/bufstack.nvim
clone nvim-shadcn ~/Code/nvim-plugins/nvim-shadcn
clone nvim-git-utils ~/Code/nvim-plugins/nvim-git-utils
clone termux-setup ~/Code/termux-setup

mkdir -p ~/.config/git/
cp ~/Code/omarchy/config/git/config ~/.gitconfig
git config --global credential.helper store
git config --global user.name "Bibek Bhusal"
git config --global user.email "bibekbhusal04@gmail.com"
source ~/Code/omarchy-overrides/config/git.sh

create_symlink ~/Code/termux-setup/configs/starship.toml ~/.config/starship.toml

if command -v tmuxinator &>/dev/null; then
  echo "tmuxinator already installed, skipping..."
else
  echo "Installing tmuxinator..."
  gem install tmuxinator
fi
create_symlink ~/Code/termux-setup/configs/tmux.conf ~/.config/tmux/tmux.conf

# Set zsh as default shell if not already
if [[ "$SHELL" != */zsh ]]; then
  echo "Setting zsh as default shell..."
  chsh -s zsh
fi

create_symlink ~/Code/omarchy/default/bash ~/.local/share/omarchy/default/bash

source ~/Code/omarchy-overrides/install/zsh-plugins.sh

write_to_file ~/.zshrc "source ~/Code/omarchy-overrides/zsh/rc.sh"

create_symlink ~/Code/termux-setup/configs/termux.properties ~/.termux/termux.properties

write_to_file ~/.bashrc "source ~/.local/share/omarchy/default/bash/envs
source ~/.local/share/omarchy/default/bash/shell
source ~/.local/share/omarchy/default/bash/aliases
source ~/.local/share/omarchy/default/bash/init
source ~/Code/omarchy-overrides/overwrite/bashrc"

if [ -f ~/.termux/font.ttf ]; then
  echo "JetBrains Mono font already installed, skipping..."
else
  echo "Installing JetBrains Mono font..."
  # install_pkg xz-utils
  curl -fLo JetBrainsMono.tar.xz "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
  tar -xf JetBrainsMono.tar.xz "JetBrainsMonoNerdFont-Regular.ttf"
  mv JetBrainsMonoNerdFont-Regular.ttf ~/.termux/font.ttf
  rm JetBrainsMono.tar.xz
  # remove_pkg xz-utils
fi

touch ~/.hushlogin
touch ~/.nomedia

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

if ! command -v devmoji &>/dev/null || ! command -v gemini &>/dev/null; then
  # Installing global npm packages
  install_npm_global devmoji
  install_npm_global @google/gemini-cli gemini
fi

install_pkg rust
source ~/Code/omarchy-overrides/install/nvim-plugins.sh
remove_pkg rust

if [ ! -d "$HOME/storage" ]; then
  echo "Setting up storage..."
  termux-setup-storage
fi

termux-reload-settings
apt autoremove -y
pkg clean -y
clear

echo "Setup almost complete, Restart the termux  run command 'nvim ~/Code/termux-setup/nextSteps.md' for next steps"
