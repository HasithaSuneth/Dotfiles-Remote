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
COMMON_PACKAGES=(zsh tmux btop fzf fd-find ripgrep)

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

install_yazi() {
    if ! command -v yazi &>/dev/null; then
        if [[ "$PM" == "dnf" ]]; then
            # sudo dnf install dnf-plugins-core
            sudo dnf copr enable -y lihaohong/yazi
            sudo dnf install -y yazi
        else
            wget -qO yazi.zip https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
            unzip -q yazi.zip -d yazi-temp
            sudo mkdir -p /usr/local/bin
            sudo mv yazi-temp/*/{ya,yazi} /usr/local/bin
            sudo chmod +x /usr/local/bin/ya /usr/local/bin/yazi
            rm -rf yazi-temp yazi.zip

            echo "✅ yazi installed."
        fi
    else
        echo "✅ yazi already installed."
    fi
}

install_lazygit() {
    if ! command -v lazygit &>/dev/null; then
        echo "🔸 Installing lazygit..."
        if [[ "$PM" == "dnf" ]]; then
            sudo dnf copr enable atim/lazygit -y
            sudo dnf install -y lazygit
        else
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
              | grep -Po '"tag_name": *"v\K[^"]*')

            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit -D -t /usr/local/bin/
            rm -f lazygit.tar.gz lazygit
        fi

        echo "✅ lazygit installed."
    else
        echo "✅ lazygit already installed."
    fi
}

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

# Atuin
install_if_missing "atuin" "atuin" \
    "bash <(curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh)"

# Starship
install_if_missing "starship" "starship" \
    "curl -sS https://starship.rs/install.sh | sh -s -- -y"

# Zoxide
install_zoxide

# Oh My Zsh
install_oh_my_zsh

# Yazi
install_yazi

# LazyGit
install_lazygit

# Eza
install_eza


echo -e "\n✅ All tools are installed and ready to use!"
