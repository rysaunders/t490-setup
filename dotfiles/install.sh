#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%s)"

FILES=(.zshrc .vimrc .tmux.conf .config/kitty .config/i3 .config/polybar .config/rofi)

echo "[*] Backing up existing dotfiles to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

for file in "${FILES[@]}"; do
    src="$DOTFILES_DIR/$file"
    dest="$HOME/$file"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$(dirname "$BACKUP_DIR/$file")"
        mv "$dest" "$BACKUP_DIR/$file"
    fi

    echo "[*] Linking $src to $dest"
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
done

echo "[*] Installing TPM (tmux plugin manager)"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || true
~/.tmux/plugins/tpm/bin/install_plugins

echo "[*] Installing vim-plug and Vim plugins"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Automatically install Vim plugins
vim +'PlugInstall --sync' +qa

echo "[✓] Dotfiles installed and plugins synced."
