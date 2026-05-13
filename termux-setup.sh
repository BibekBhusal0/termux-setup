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
  ripgrep
  starship
  stylua
  termux-api
  tmux
  zoxide
  zsh
  nodejs
)

for pkg in "${packages[@]}"; do
  install_pkg "$pkg"
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
    mkdir -p "$(dirname "$target_dir")"
    if [ "$shallow" = "true" ]; then
      git clone --depth 10 "$repo_url" "$target_dir"
    else
      git clone "$repo_url" "$target_dir"
    fi
  fi
}

clone omarchy-overrides ~/Code/omarchy-overrides
clone basecamp/omarchy ~/Code/omarchy true
clone neovim-kickstart-config-config ~/.config/nvim
clone bufstack.nvim ~/Code/nvim-plugins/bufstack.nvim
clone nvim-shadcn ~/Code/nvim-plugins/nvim-shadcn
clone nvim-git-utils ~/Code/nvim-plugins/nvim-git-utils
clone termux-setup ~/Code/termux-setup
clone tmux-plugins/tpm ~/.tmux/plugins/tpm

mkdir -p ~/.config/git/
cp ~/Code/omarchy/config/git/config ~/.gitconfig
git config --global credential.helper store
git config --global user.name "Bibek Bhusal"
git config --global user.email "bibekbhusal04@gmail.com"
source ~/Code/omarchy-overrides/git-config.sh

write_to_file() {
  local file="$1"
  local overwrite="${2:-false}"

  mkdir -p "$(dirname "$file")"

  local content_to_write
  content_to_write=$(cat -)

  local file_exists=false
  if [ -f "$file" ]; then
    file_exists=true
  fi

  if "$file_exists"; then
    local existing_file_content=$(<"$file")
    if [[ "$existing_file_content" == *"$content_to_write"* ]]; then
      echo "Content already present in $file. Skipping ..."
      return 0
    fi
  fi

  if [ "$overwrite" = "true" ]; then
    echo "$content_to_write" > "$file"
    echo "Overwritten $file"
  else
    echo "$content_to_write" >> "$file"
    echo "Appended to: $file"
  fi
}

mkdir -p ~/.config
cp ~/Code/omarchy/config/starship.toml ~/.config/starship.toml

write_to_file ~/.config/starship.toml <<'EOF'
[custom.device]
command = 'echo "${HOSTNAME:-phone}"'
when = 'test -n "$SSH_TTY"'
format = "[@$output]($style) "
style = "bold yellow"
EOF

sed -i 's/format = "\[$directory$git_branch$git_status\]($style)$character"/format = "[$custom$directory$git_branch$git_status]($style)$character"/' ~/.config/starship.toml

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

source ~/Code/omarchy-overrides/install/zsh-plugins.sh

write_to_file ~/.zshrc true << EOF
source ~/Code/omarchy-overrides/zsh/rc.sh
EOF


write_to_file ~/.termux/termux.properties << EOF
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
  # install_pkg xz-utils
  curl -fLo JetBrainsMono.tar.xz "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
  tar -xf JetBrainsMono.tar.xz "JetBrainsMonoNerdFont-Regular.ttf"
  mv JetBrainsMonoNerdFont-Regular.ttf ~/.termux/font.ttf
  rm JetBrainsMono.tar.xz
  # remove_pkg xz-utils
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

if ! command -v devmoji &>/dev/null || ! command -v gemini &>/dev/null; then
  # Installing global npm packages
  install_npm_global devmoji
  install_npm_global @google/gemini-cli gemini
fi

install_pkg rust
source ~/Code/omarchy-overrides/overwrite/nvim-plugis.sh
remove_pkg rust

echo "Installing Tmux plugins..."
~/.tmux/plugins/tpm/bin/install_plugins || true

if [ ! -d "$HOME/storage" ]; then
  echo "Setting up storage..."
  termux-setup-storage
fi

termux-reload-settings
apt autoremove -y
pkg clean -y
clear

echo "Setup almost complete, Restart the termux  run command 'nvim ~/Code/termux-setup/nextSteps.md' for next steps"
