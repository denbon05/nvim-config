# nvim-config

My personal Neovim config, built up in small steps while I learn. It uses Neovim's built-in plugin manager, `vim.pack`, and only ten plugins.

Tested on Neovim 0.12.6 on macOS.

## Install

```sh
git clone git@github.com:denbon05/nvim-config.git ~/.config/nvim
brew bundle --file ~/.config/nvim/Brewfile
```

`brew bundle` installs every tool listed in `Brewfile`: Neovim, the search tools, the language servers, the tree-sitter CLI and delta, which shows diffs.

On the first start, Neovim asks before downloading the plugins: press `y`. The syntax parsers are then built in the background, so restart Neovim once more to see the colors. The versions are pinned in `nvim-pack-lock.json`.

The icons (in markdown headings, checkboxes and code blocks) come from Symbols Nerd Font, which the Brewfile installs. Tell iTerm to use it for them: Settings → Profiles → Text, tick "Use a different font for non-ASCII text" and pick "Symbols Nerd Font Mono". The letters stay in the main font. Without it the icons show as empty boxes.

For a Python project that uses uv, start Neovim with `uv run nvim .` so basedpyright can find the packages in `.venv`.

delta shows the diffs of `git diff` and of `Space` `g`. Its settings live in `~/.gitconfig`, which is not in this repo, so add them there on a new machine:

```ini
[core]
	pager = delta
[interactive]
	diffFilter = delta --color-only
[delta]
	navigate = true
	line-numbers = true
	# Show only the new file's line numbers: one column instead of two.
	# A deleted line gets no number, it is not in the new file.
	line-numbers-left-format = ""
	pager = less -iR
[delta "wide"]
	side-by-side = true
```

Caps Lock works as `Ctrl` when held with another key and as `Esc` when tapped alone, so the left little finger reaches both from where it rests. Esc, in turn, turns Caps Lock on and off. macOS can't give one key two roles, so Karabiner-Elements does it (it is in the `Brewfile`); the rule is `karabiner/caps-lock.json`. On a new machine:

1. Open Karabiner-Elements and allow what macOS asks for: its driver extension and Input Monitoring.
2. Copy the rule where Karabiner looks for rules:

   ```sh
   mkdir -p ~/.config/karabiner/assets/complex_modifications
   cp ~/.config/nvim/karabiner/caps-lock.json ~/.config/karabiner/assets/complex_modifications/
   ```

3. In Karabiner-Elements: Complex Modifications → Add predefined rule → "Caps Lock: Ctrl when held, Esc when tapped; Esc: Caps Lock" → Enable All.

Leave macOS's own Modifier Keys setting at its defaults, so the two don't remap the same key.

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
├── karabiner/
│   └── caps-lock.json     Caps Lock: Ctrl when held, Esc when tapped; Esc: Caps Lock
├── nvim-pack-lock.json    Plugin versions, written by vim.pack
├── syntax/
│   └── cedar.lua          Colors for Cedar and Dogwood policies and Cedar schemas
└── lua/config/
    ├── options.lua        Editor settings
    ├── keymaps.lua        Shortcuts
    ├── plugins.lua        fzf-lua: find files and search text
    ├── lsp.lua            Language servers: errors, go to definition, completion
    ├── colors.lua         Color scheme: VS Code light and dark, follows the terminal
    ├── treesitter.lua     Detailed syntax highlighting with tree-sitter
    ├── diff.lua           Git changes inside the file, jumps between them
    ├── jumps.lua          [m and ]m land on function and class names
    ├── links.lua          gf opens markdown links at their heading
    ├── markdown.lua       Markdown drawn readable in the file, and previewed in the browser
    └── cedar.lua          .dw and .cedarschema files open as Cedar
```

## Shortcuts

The leader key is Space. Every shortcut, my own and the built-in ones I use, is in [CHEATSHEET.md](CHEATSHEET.md). Inside Neovim, `Space` `?` opens it.

## Plan

Each stage is added only when I feel the need for it.

- [x] Stage 1: settings and shortcuts, no plugins
- [x] Stage 2: file and text search with fzf-lua
- [x] Stage 3: code intelligence with language servers
- [x] Stage 4: color scheme and tree-sitter highlighting
