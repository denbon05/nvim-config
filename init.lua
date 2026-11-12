-- This is the first file Neovim runs when it starts.
-- Lines starting with two dashes are comments. Neovim ignores them.

-- The "leader" is a prefix key for your own shortcuts. We chose Space.
-- It has to be set before the shortcuts are created, so it comes first.
vim.g.mapleader = " "

-- The same idea, for shortcuts that apply to one file type only.
vim.g.maplocalleader = " "

-- Run lua/config/options.lua, which holds the editor settings.
require("config.options")

-- Run lua/config/keymaps.lua, which holds your shortcuts.
require("config.keymaps")

-- Run lua/config/plugins.lua, which loads the plugins.
require("config.plugins")

-- Run lua/config/lsp.lua, which starts the language servers.
require("config.lsp")

-- Run lua/config/colors.lua, which sets the color scheme.
require("config.colors")

-- Run lua/config/treesitter.lua, which turns on detailed syntax highlighting.
require("config.treesitter")

-- Run lua/config/diff.lua, which shows git changes inside the file.
require("config.diff")
