#!/data/data/com.termux/files/usr/bin/bash

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
  rust
  starship
  stylua
  termux-api
  tmux
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

git config --global credential.helper store
git config --global user.name "Bibek Bhusal"
git config --global user.email "bibekbhusal04@gmail.com"

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

mkdir -p ~/.config/git/
ln -sf ~/Code/omarchy/config/starship.toml ~/.config/starship.toml
ln -sf ~/Code/omarchy/config/git/config ~/.config/git/config

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

~/Code/omarchy-overrides/install/zsh-plugins.sh

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
echo "Installing Neovim plugins (headless)..."
max_retries=5
count=0
success=false

while [ $count -lt $max_retries ]; do
  if nvim --headless --cmd "let g:lazy_concurrency=1" "+Lazy! sync" +qa; then
    success=true
    break
  fi
  count=$((count+1))
  if [ $count -lt $max_retries ]; then
    echo "Neovim plugin installation failed (Attempt $count). Retrying in 5 seconds..."
    sleep 5
  fi
done

if [ "$success" = false ]; then
  echo "Warning: Neovim plugins failed to install after $max_retries attempts. Continuing setup..."
fi

echo "Installing Tmux plugins..."
~/.tmux/plugins/tpm/bin/install_plugins || true

if [ ! -d "$HOME/storage" ]; then
  echo "Setting up storage..."
  termux-setup-storage
fi

termux-reload-settings
clear

echo "Setup almost complete, Restart the termux  run command 'nvim ~/Code/termux-setup/nextSteps.md' for next steps"
