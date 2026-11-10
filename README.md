# nvim-config

My personal Neovim config, built up in small steps while I learn. It uses Neovim's built-in plugin manager, `vim.pack`, and only two plugins.

Tested on Neovim 0.12.6 on macOS.

## Install

```sh
git clone git@github.com:denbon05/nvim-config.git ~/.config/nvim
brew install fzf ripgrep fd pyright ruff typescript-language-server
```

On the first start, Neovim asks before downloading the plugins: press `y`. The versions are pinned in `nvim-pack-lock.json`.

For a Python project that uses uv, start Neovim with `uv run nvim .` so Pyright can find the packages in `.venv`.

## Layout

```
~/.config/nvim/
├── init.lua               Entry point: sets the leader key, loads the modules
├── nvim-pack-lock.json    Plugin versions, written by vim.pack
└── lua/config/
    ├── options.lua        Editor settings
    ├── keymaps.lua        Shortcuts
    ├── plugins.lua        fzf-lua: find files and search text
    └── lsp.lua            Language servers: errors, go to definition, completion
```

## Shortcuts

The leader key is Space. Keys are tapped one after another, except `Ctrl`, which is held.

| Keys | Action |
|---|---|
| `Space` `w` | Save the file |
| `Space` `e` | Show or hide the file list on the left |
| `Space` `f` | Find a file by name |
| `Space` `/` | Search for text in the project |
| `Space` `b` | Pick an open file |
| `gd` | Go to definition (when a language server is running) |
| `Esc` | Clear search highlights |
| `Ctrl-h` / `j` / `k` / `l` | Move between splits |

Neovim's own LSP keys also work: `K` hover, `grn` rename, `grr` references, `gra` code action, `]d` / `[d` next or previous error, `Ctrl-w d` show the error.

## Plan

Each stage is added only when I feel the need for it.

- [x] Stage 1: settings and shortcuts, no plugins
- [x] Stage 2: file and text search with fzf-lua
- [x] Stage 3: code intelligence with language servers
