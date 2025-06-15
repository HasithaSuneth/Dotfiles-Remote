#!/bin/bash

set -e

# Ensure ~/.local/bin is in PATH for current session
export PATH="$HOME/.local/bin:$PATH"

# Detect package manager
if command -v dnf &>/dev/null; then
    PM="dnf"
elif command -v apt &>/dev/null; then
    PM="apt"
else
    echo "❌ Unsupported distribution. Only supports apt and dnf based systems."
    exit 1
fi

echo "📦 Detected package manager: $PM"

# Update system package index
echo "🔄 Updating package index..."
if [[ "$PM" == "apt" ]]; then
    sudo apt update
    sudo apt install -y curl git
elif [[ "$PM" == "dnf" ]]; then
    sudo dnf makecache
    sudo dnf install -y curl git
fi

# Common package list
COMMON_PACKAGES=(zsh tmux fzf fd-find ripgrep)

# Install common packages
echo "📥 Installing common packages..."
for pkg in "${COMMON_PACKAGES[@]}"; do
    if ! command -v "${pkg}" &>/dev/null && ! command -v "${pkg/fd-find/fdfind}" &>/dev/null; then
        echo "🔹 Installing $pkg..."
        sudo $PM install -y "$pkg"
    else
        echo "✅ $pkg already installed."
    fi
done

# Handle fd alias on Ubuntu/Debian
if [[ "$PM" == "apt" ]] && ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
    echo "⚙️  Adding alias for fd as fdfind..."
    echo 'alias fd=fdfind' >> ~/.zshrc
fi

install_eza() {
    if ! command -v eza &>/dev/null; then
        echo "🔸 Installing eza..."

        if [[ "$PM" == "dnf" ]]; then
            sudo dnf install -y eza
        else
            # Setup GPG key and repo only if not already done
            if [[ ! -f /etc/apt/keyrings/eza.gpg ]]; then
                echo "🔑 Adding eza GPG key and repo..."
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
                    sudo gpg --dearmor -o /etc/apt/keyrings/eza.gpg
                echo "deb [signed-by=/etc/apt/keyrings/eza.gpg] http://deb.gierens.de stable main" | \
                    sudo tee /etc/apt/sources.list.d/eza.list > /dev/null
                sudo chmod 644 /etc/apt/keyrings/eza.gpg /etc/apt/sources.list.d/eza.list
            fi

            sudo apt update
            sudo apt install -y eza
        fi

        echo "✅ eza installed."
    else
        echo "✅ eza already installed."
    fi
}

install_zoxide() {
    if ! command -v zoxide &>/dev/null; then
        echo "🔸 Installing zoxide..."

        if [[ "$PM" == "dnf" ]]; then
            sudo dnf install -y zoxide
        else
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        fi

        echo "✅ zoxide installed."
    else
        echo "✅ zoxide already installed."
    fi
}

# Optional/custom tools
echo "✨ Installing optional tools..."

# Zoxide
install_zoxide

# Eza
install_eza


echo -e "\n✅ All tools are installed and ready to use!"
