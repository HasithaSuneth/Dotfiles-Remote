#!/bin/bash
set -e

echo "🚀 Starting dotfiles setup..."

REPO_DIR="$(pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%s)"
CONFIG_SRC="$REPO_DIR/Configs/.config"
DOTFILES_SRC="$REPO_DIR/Configs"

mkdir -p "$BACKUP_DIR"
echo "📦 Backup directory: $BACKUP_DIR"

# 1. Copy ~/.config files
echo "📁 Installing config files to ~/.config"
mkdir -p "$HOME/.config"
for config in "$CONFIG_SRC"/*; do
    name=$(basename "$config")
    target="$HOME/.config/$name"
    if [ -e "$target" ]; then
        echo "🔁 Backing up $target to $BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
    fi
    cp -r "$config" "$target"
done

# 2. Copy dotfiles
echo "📁 Installing home directory dotfiles"
for dotfile in "$DOTFILES_SRC"/.*; do
    filename=$(basename "$dotfile")

    # Skip . and ..
    [[ "$filename" == "." || "$filename" == ".." || "$filename" == ".config" ]] && continue

    target="$HOME/$filename"
    if [ -e "$target" ]; then
        echo "🔁 Backing up $target to $BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
    fi
    cp "$dotfile" "$target"
done

echo "✅ Dotfiles setup completed!"
