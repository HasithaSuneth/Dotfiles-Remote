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
COMMON_PACKAGES=(zsh tmux btop fzf fd-find)

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

# Function to install tools if not already installed
install_if_missing() {
    local name="$1"
    local cmd="$2"
    local install_cmd="$3"

    if ! command -v "$cmd" &>/dev/null; then
        echo "🔸 Installing $name..."
        eval "$install_cmd"
    else
        echo "✅ $name already installed."
    fi
}

# Optional/custom tools
echo "✨ Installing optional tools..."

# Zoxide
install_if_missing "zoxide" "zoxide" \
    "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"

# Yazi
install_if_missing "yazi" "yazi" \
    "bash <(curl -sSL https://raw.githubusercontent.com/sxyazi/yazi/main/install.sh)"

# Atuin
install_if_missing "atuin" "atuin" \
    "bash <(curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh)"

# Starship
install_if_missing "starship" "starship" \
    "curl -sS https://starship.rs/install.sh | sh -s -- -y"

install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "🔸 Installing oh-my-zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

        ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

        if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        fi

        if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        fi

        echo "✅ oh-my-zsh installed."
    else
        echo "✅ oh-my-zsh already installed."
    fi
}

# Oh My Zsh
install_oh_my_zsh

# LazyGit
if ! command -v lazygit &>/dev/null; then
    if [[ "$PM" == "dnf" ]]; then
        sudo dnf copr enable atim/lazygit -y
        sudo dnf install -y lazygit
    else
        sudo apt install -y lazygit
    fi
else
    echo "✅ lazygit already installed."
fi


echo -e "\n✅ All tools are installed and ready to use!"
