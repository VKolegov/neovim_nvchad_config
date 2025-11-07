#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Detect package manager
detect_package_manager() {
    if check_command apt-get; then
        echo "apt"
    elif check_command dnf; then
        echo "dnf"
    elif check_command yum; then
        echo "yum"
    elif check_command pacman; then
        echo "pacman"
    elif check_command brew; then
        echo "brew"
    else
        echo "unknown"
    fi
}

echo ""
info "Neovim Configuration - Dependency Installer"
echo ""

# Check for required base tools
info "Checking base requirements..."

if ! check_command node; then
    error "Node.js is not installed. Please install Node.js >= 18.x first."
    exit 1
fi

if ! check_command npm; then
    error "npm is not installed. Please install npm first."
    exit 1
fi

success "Node.js and npm are installed"

# Detect system package manager
PKG_MANAGER=$(detect_package_manager)
info "Detected package manager: $PKG_MANAGER"

# Install system dependencies (cmake, gcc)
echo ""
info "Installing build tools (cmake, gcc)..."

case $PKG_MANAGER in
    apt)
        sudo apt-get update
        sudo apt-get install -y cmake gcc g++
        ;;
    dnf)
        sudo dnf install -y cmake gcc gcc-c++
        ;;
    yum)
        sudo yum install -y cmake gcc gcc-c++
        ;;
    pacman)
        sudo pacman -S --noconfirm cmake gcc
        ;;
    brew)
        brew install cmake
        ;;
    *)
        warn "Could not auto-install build tools. Please install manually:"
        echo "  - cmake"
        echo "  - gcc/clang"
        ;;
esac

if check_command cmake; then
    success "Build tools installed"
else
    warn "Build tools may not be installed correctly"
fi

# Install LSP servers via npm
echo ""
info "Installing LSP servers via npm..."

npm install -g vscode-langservers-extracted  # HTML, CSS, JSON, ESLint
npm install -g sql-language-server
npm install -g @vtsls/language-server
npm install -g @vue/language-server

success "npm LSP servers installed"

# Install Go LSP (gopls)
echo ""
if check_command go; then
    info "Installing Go LSP server (gopls)..."
    go install golang.org/x/tools/gopls@latest
    success "gopls installed"
else
    warn "Go is not installed. Skipping gopls installation."
    echo "  To install gopls later: go install golang.org/x/tools/gopls@latest"
fi

# Install Python LSP (pyright)
echo ""
if check_command pip3 || check_command pip; then
    info "Installing Python LSP server (pyright)..."

    if check_command pip3; then
        pip3 install --user pyright
    else
        pip install --user pyright
    fi

    success "pyright installed"
else
    warn "pip is not installed. Skipping pyright installation."
    echo "  To install pyright later: pip install pyright"
fi

# Install PHP LSP (phpactor)
echo ""
if check_command composer; then
    info "Installing PHP LSP server (phpactor)..."
    composer global require phpactor/phpactor
    success "phpactor installed"
elif check_command php; then
    warn "Composer is not installed, but PHP is available."
    echo "  Install phpactor manually:"
    echo "  curl -Lo phpactor.phar https://github.com/phpactor/phpactor/releases/latest/download/phpactor.phar"
    echo "  chmod +x phpactor.phar"
    echo "  sudo mv phpactor.phar /usr/local/bin/phpactor"
else
    warn "PHP is not installed. Skipping phpactor installation."
fi

# Install intelephense (alternative PHP LSP)
if check_command npm; then
    echo ""
    read -p "Install intelephense (alternative PHP LSP)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        npm install -g intelephense
        success "intelephense installed"
    fi
fi

# Install formatters
echo ""
info "Installing formatters..."

if check_command cargo; then
    info "Installing stylua (Lua formatter)..."
    cargo install stylua
    success "stylua installed"
else
    warn "Rust/Cargo is not installed. Skipping stylua installation."
    echo "  To install stylua later:"
    echo "  - Install Rust: https://rustup.rs/"
    echo "  - Then: cargo install stylua"
    echo "  Or use your package manager (e.g., brew install stylua)"
fi

# Summary
echo ""
echo "======================================"
info "Installation Summary"
echo "======================================"

echo ""
echo "LSP Servers:"
check_command vscode-html-language-server && success "✓ HTML LSP" || warn "✗ HTML LSP"
check_command vscode-css-language-server && success "✓ CSS LSP" || warn "✗ CSS LSP"
check_command sql-language-server && success "✓ SQL LSP" || warn "✗ SQL LSP"
check_command vtsls && success "✓ TypeScript/JavaScript LSP" || warn "✗ TypeScript/JavaScript LSP"
check_command vue-language-server && success "✓ Vue LSP" || warn "✗ Vue LSP"
check_command gopls && success "✓ Go LSP" || warn "✗ Go LSP"
check_command pyright-langserver && success "✓ Python LSP" || warn "✗ Python LSP"
check_command phpactor && success "✓ PHP LSP (phpactor)" || warn "✗ PHP LSP (phpactor)"

echo ""
echo "Formatters:"
check_command stylua && success "✓ stylua (Lua)" || warn "✗ stylua (Lua)"

echo ""
echo "Build Tools:"
check_command cmake && success "✓ cmake" || warn "✗ cmake"
check_command gcc && success "✓ gcc" || warn "✗ gcc"

echo ""
echo "======================================"
success "Dependency installation complete!"
echo "======================================"

echo ""
info "Next steps:"
echo "  1. Launch Neovim: nvim"
echo "  2. Plugins will auto-install via lazy.nvim"
echo "  3. Check LSP status: :LspInfo"
echo "  4. Update plugins: :Lazy update"
echo ""
