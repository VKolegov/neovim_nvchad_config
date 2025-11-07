#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

banner() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║   Neovim Configuration Bootstrap      ║"
    echo "║   Based on NvChad v2.5                ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

version_ge() {
    [ "$1" = "$(echo -e "$1\n$2" | sort -V | tail -n1)" ]
}

banner

echo ""
info "Starting bootstrap process..."
echo ""

# Check Neovim version
info "Checking Neovim version..."

if ! check_command nvim; then
    error "Neovim is not installed!"
    echo ""
    echo "Please install Neovim >= 0.10.0 first:"
    echo "  - Ubuntu/Debian: https://github.com/neovim/neovim/releases"
    echo "  - macOS: brew install neovim"
    echo "  - Arch: sudo pacman -S neovim"
    exit 1
fi

NVIM_VERSION=$(nvim --version | head -n1 | awk '{print $2}' | sed 's/v//')
REQUIRED_VERSION="0.10.0"

if ! version_ge "$NVIM_VERSION" "$REQUIRED_VERSION"; then
    error "Neovim version $NVIM_VERSION is too old!"
    echo "Required: >= $REQUIRED_VERSION"
    echo "Please upgrade Neovim: https://github.com/neovim/neovim/releases"
    exit 1
fi

success "Neovim $NVIM_VERSION detected (>= $REQUIRED_VERSION)"

# Check if Git is installed
info "Checking Git..."

if ! check_command git; then
    error "Git is not installed!"
    echo "Please install Git first."
    exit 1
fi

success "Git is installed"

# Check if config already exists
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
CURRENT_DIR="$(pwd)"

echo ""
if [ "$CURRENT_DIR" = "$NVIM_CONFIG_DIR" ]; then
    info "Running from Neovim config directory: $NVIM_CONFIG_DIR"
    info "Skipping clone/backup (already in place)"
else
    info "Target directory: $NVIM_CONFIG_DIR"

    if [ -d "$NVIM_CONFIG_DIR" ]; then
        warn "Existing Neovim config found at $NVIM_CONFIG_DIR"
        BACKUP_DIR="$NVIM_CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"

        read -p "Create backup and replace? [y/N] " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Creating backup at $BACKUP_DIR"
            mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
            success "Backup created"

            info "Copying current config to $NVIM_CONFIG_DIR"
            cp -r "$CURRENT_DIR" "$NVIM_CONFIG_DIR"
            success "Config copied"
        else
            warn "Bootstrap cancelled by user"
            exit 0
        fi
    else
        info "No existing config found"
        info "Copying current config to $NVIM_CONFIG_DIR"
        mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"
        cp -r "$CURRENT_DIR" "$NVIM_CONFIG_DIR"
        success "Config copied to $NVIM_CONFIG_DIR"
    fi
fi

# Check if lazy.nvim will auto-bootstrap
echo ""
info "Checking lazy.nvim plugin manager..."

LAZY_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"

if [ -d "$LAZY_PATH" ]; then
    success "lazy.nvim already installed"
else
    info "lazy.nvim will auto-bootstrap on first Neovim launch"
fi

# Prompt for dependency installation
echo ""
info "External dependencies (LSP servers, formatters) need to be installed separately."

if [ -f "$NVIM_CONFIG_DIR/install-deps.sh" ]; then
    read -p "Run dependency installer now? [Y/n] " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo ""
        info "Running install-deps.sh..."
        echo ""
        "$NVIM_CONFIG_DIR/install-deps.sh"
    else
        warn "Skipping dependency installation"
        echo "  Run later with: cd $NVIM_CONFIG_DIR && ./install-deps.sh"
    fi
else
    warn "install-deps.sh not found. You'll need to install LSP servers manually."
fi

# Final message
echo ""
echo "======================================"
success "Bootstrap complete!"
echo "======================================"
echo ""
info "Next steps:"
echo "  1. Launch Neovim: ${CYAN}nvim${NC}"
echo "  2. Wait for plugins to install automatically"
echo "  3. Restart Neovim after installation"
echo "  4. Check LSP status: ${CYAN}:LspInfo${NC}"
echo "  5. View keybindings: ${CYAN}<Space>ch${NC} (in Neovim)"
echo ""
info "Useful commands:"
echo "  - Update plugins: ${CYAN}:Lazy update${NC}"
echo "  - Plugin status: ${CYAN}:Lazy${NC}"
echo "  - LSP info: ${CYAN}:LspInfo${NC}"
echo ""

read -p "Launch Neovim now? [Y/n] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo ""
    info "Launching Neovim..."
    sleep 1
    nvim
else
    echo ""
    success "Setup complete. Launch Neovim when ready!"
fi
