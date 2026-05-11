# Next Steps

To complete your setup, please perform the following manual steps:

## 1. Login to Gemini CLI
Run the following command to authenticate (if already not logged in):
```bash
gemini
```

## 2. Setup GitHub CLI (gh)
Authenticate with GitHub to enable git push/pull:
```bash
gh auth login
```

## 3. Create Obsidian Symlink
Create a symlink from Obsidian vault to Documents to use obsidian nvim plugin.
```bash
mkdir -p ~/Documents/
ln -s ~/storage/shared/obsidian/vault ~/Documents/vault
```
