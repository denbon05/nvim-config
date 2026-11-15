# nvim-config

My personal Neovim config, built up in small steps while I learn. It uses Neovim's built-in plugin manager, `vim.pack`, and only four plugins.

Tested on Neovim 0.12.6 on macOS.

## Install

```sh
git clone git@github.com:denbon05/nvim-config.git ~/.config/nvim
brew bundle --file ~/.config/nvim/Brewfile
```

`brew bundle` installs every tool listed in `Brewfile`: Neovim, the search tools, the language servers, the tree-sitter CLI and delta, which shows diffs.

On the first start, Neovim asks before downloading the plugins: press `y`. The syntax parsers are then built in the background, so restart Neovim once more to see the colors. The versions are pinned in `nvim-pack-lock.json`.

For a Python project that uses uv, start Neovim with `uv run nvim .` so Pyright can find the packages in `.venv`.

## Update

On a machine that already has the config:

```sh
git -C ~/.config/nvim pull
brew bundle --file ~/.config/nvim/Brewfile
```

Then start Neovim, or run `:restart` if it is open. A plugin that was added is downloaded on that start: press `y` when Neovim asks. If the pull changed the version of a plugin that is already installed, run `:lua vim.pack.update(nil, { target = "lockfile" })` and confirm with `:w`.

## Layout

```
~/.config/nvim/
├── init.lua               Entry point: sets the leader key, loads the modules
├── Brewfile               Homebrew packages the config needs
├── CHEATSHEET.md          Every shortcut I use
├── nvim-pack-lock.json    Plugin versions, written by vim.pack
└── lua/config/
    ├── options.lua        Editor settings
    ├── keymaps.lua        Shortcuts
    ├── plugins.lua        fzf-lua: find files and search text
    ├── lsp.lua            Language servers: errors, go to definition, completion
    ├── colors.lua         Color scheme: VS Code light and dark, follows the terminal
    ├── treesitter.lua     Detailed syntax highlighting with tree-sitter
    └── diff.lua           Git changes inside the file, jumps between them
```

## Shortcuts

The leader key is Space. Every shortcut, my own and the built-in ones I use, is in [CHEATSHEET.md](CHEATSHEET.md). Inside Neovim, `Space` `?` opens it.

## Plan

Each stage is added only when I feel the need for it.

- [x] Stage 1: settings and shortcuts, no plugins
- [x] Stage 2: file and text search with fzf-lua
- [x] Stage 3: code intelligence with language servers
- [x] Stage 4: color scheme and tree-sitter highlighting
