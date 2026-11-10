# nvim-config

My personal Neovim config, built up in small steps while I learn. It has no plugins yet.

Tested on Neovim 0.12.6 on macOS.

## Install

```sh
git clone git@github.com:denbon05/nvim-config.git ~/.config/nvim
```

## Layout

```
~/.config/nvim/
├── init.lua               Entry point: sets the leader key, loads the modules
└── lua/config/
    ├── options.lua        Editor settings
    └── keymaps.lua        Shortcuts
```

## Shortcuts

The leader key is Space. Keys are tapped one after another, except `Ctrl`, which is held.

| Keys | Action |
|---|---|
| `Space` `w` | Save the file |
| `Space` `e` | Open the file explorer |
| `Esc` | Clear search highlights |
| `Ctrl-h` / `j` / `k` / `l` | Move between splits |

## Plan

Each stage is added only when I feel the need for it.

- [x] Stage 1: settings and shortcuts, no plugins
- [ ] Stage 2: file and text search with fzf-lua
- [ ] Stage 3: code intelligence with language servers
