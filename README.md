# Personal Neovim Configuration

A portable, modern Neovim configuration based on [NvChad v2.5](https://nvchad.com/), featuring native LSP support for multiple languages and a streamlined development workflow.

## Features

- **NvChad v2.5** as base framework for UI and plugin management
- **Native LSP** configuration using Neovim 0.10+ `vim.lsp.config` API
- **Multi-language support** with preconfigured LSP servers:
  - HTML, CSS, SCSS, Less
  - PHP (phpactor)
  - SQL
  - TypeScript, JavaScript, JSX, TSX
  - Vue.js
  - Go
  - Python (with Conda support)
- **Code formatting** with conform.nvim
- **Enhanced search** with Telescope + fzf-native
- **Remote editing** with distant.nvim
- **Custom commands** and keybindings

## Prerequisites

- **Neovim** >= 0.10.0
- **Git** >= 2.19.0
- **Node.js** >= 18.x (for some LSP servers)
- A [Nerd Font](https://www.nerdfonts.com/) for icons (optional but recommended)
- **C/C++ compiler** (gcc/clang) and **cmake** for telescope-fzf-native

## Quick Start

### New Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git ~/.config/nvim
   cd ~/.config/nvim
   ```

2. **Run the bootstrap script:**
   ```bash
   ./bootstrap.sh
   ```

3. **Install external dependencies:**
   ```bash
   ./install-deps.sh
   ```

4. **Launch Neovim:**
   ```bash
   nvim
   ```
   Plugins will install automatically via lazy.nvim on first launch.

### Syncing to a New Device

If you already have this config set up in a git repository:

```bash
git clone <your-repo-url> ~/.config/nvim
cd ~/.config/nvim
./bootstrap.sh
./install-deps.sh
nvim
```

## Project Structure

```
~/.config/nvim/
├── init.lua                    # Main entry point
├── lazy-lock.json              # Plugin version lock file (tracked in git)
├── .gitignore                  # Excludes local files (pack/, backups)
├── lua/
│   ├── configs/
│   │   ├── conform.lua         # Code formatting configuration
│   │   ├── lazy.lua            # Lazy.nvim plugin manager config
│   │   └── native_lsp.lua      # Native LSP server configurations
│   ├── plugins/
│   │   ├── init.lua            # Custom plugin definitions
│   │   └── disabled.lua        # Disabled NvChad plugins
│   ├── chadrc.lua              # NvChad theme and UI settings
│   ├── mappings.lua            # Custom keybindings
│   └── options.lua             # Neovim options
├── install-deps.sh             # Installs LSP servers and tools
└── bootstrap.sh                # One-command setup for new machines
```

## LSP Servers

This configuration includes native LSP support for:

| Language         | LSP Server                      | Filetypes                       |
|------------------|---------------------------------|---------------------------------|
| HTML             | vscode-html-language-server     | html                            |
| CSS              | vscode-css-language-server      | css, scss, less                 |
| PHP              | phpactor                        | php                             |
| SQL              | sql-language-server             | sql                             |
| TypeScript/JS    | vtsls                           | typescript, javascript, jsx, tsx |
| Vue.js           | vue-language-server             | vue                             |
| Go               | gopls                           | go                              |
| Python           | pyright-langserver              | python                          |

**Note:** LSP servers must be installed separately. Use `./install-deps.sh` for automatic installation.

## Custom Keybindings

| Mode   | Key    | Action                  | Description                        |
|--------|--------|-------------------------|------------------------------------|
| Normal | `;`    | `:`                     | Enter command mode (faster than `:`) |
| Insert | `jk`   | `<ESC>`                 | Exit insert mode                   |

Additionally, all default NvChad keybindings are available. Press `<Space>ch` in Neovim to view the cheatsheet.

## Custom Commands

### `:FormatFiles <directory> <extension>`

Batch format all files of a specific type in a directory (recursively).

**Example:**
```vim
:FormatFiles src go
```

This will:
- Find all `.go` files in `src/` and subdirectories
- Exclude `node_modules/`, `vendor/`, and `pkg/mod/`
- Format each file using LSP formatter
- Save changes automatically

## Configuration Highlights

### Special Settings

- **Mouse disabled** (`vim.opt.mouse = ""`)
- **Relative line numbers** enabled
- **Virtual text diagnostics** disabled (cleaner UI)
- **PHP-specific:** `$` added to `iskeyword` for variable highlighting
- **Python:** Conda environment auto-detection

### Plugin Management

- **lazy.nvim** handles all plugins (auto-bootstraps on first launch)
- **lazy-lock.json** ensures consistent plugin versions across devices
- Update plugins: `:Lazy update`
- Check plugin status: `:Lazy`

## External Dependencies

The following tools need to be installed on your system:

### LSP Servers
```bash
npm install -g vscode-langservers-extracted  # HTML, CSS
npm install -g sql-language-server
npm install -g @vtsls/language-server
npm install -g @vue/language-server
go install golang.org/x/tools/gopls@latest
pip install pyright
# PHP: Install phpactor via composer or system package manager
```

### Formatters
```bash
cargo install stylua  # Lua formatter
```

### Build Tools
```bash
# Ubuntu/Debian
sudo apt install cmake gcc

# macOS
brew install cmake

# Arch Linux
sudo pacman -S cmake gcc
```

**Tip:** Use the `./install-deps.sh` script to automate installation.

## Updating

### Update Plugins
```bash
nvim
:Lazy update
```

### Update Config
```bash
cd ~/.config/nvim
git pull
```

## Troubleshooting

### Plugins not loading
```vim
:Lazy sync
```

### LSP not working
1. Check if LSP server is installed:
   ```bash
   which gopls  # for Go example
   ```
2. Check LSP status in Neovim:
   ```vim
   :LspInfo
   ```

### telescope-fzf-native build failed
Install cmake and a C compiler:
```bash
# Ubuntu/Debian
sudo apt install cmake gcc

# macOS
brew install cmake
```

### Python LSP not detecting Conda environment
Ensure your Conda environment is activated before launching Neovim:
```bash
conda activate myenv
nvim
```

## Customization

### Adding a New LSP Server

Edit `lua/configs/native_lsp.lua`:

```lua
vim.lsp.config.rust_analyzer = {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
}
vim.lsp.enable { "rust_analyzer" }
```

### Changing Theme

Edit `lua/chadrc.lua` and modify the theme settings.

### Adding Plugins

Add plugins to `lua/plugins/init.lua`:

```lua
{
  "your-username/plugin-name",
  config = function()
    require("plugin-name").setup()
  end,
}
```

## Credits

- [NvChad](https://nvchad.com/) - Base framework
- [LazyVim starter](https://github.com/LazyVim/starter) - Inspiration for structure
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager

## License

See [LICENSE](LICENSE) file for details.
