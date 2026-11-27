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

-- Run lua/config/jumps.lua, which makes [m and ]m land on function names.
require("config.jumps")

-- Run lua/config/links.lua, which makes gf open markdown links at a heading.
require("config.links")

-- Run lua/config/markdown.lua, which draws markdown files in a readable way.
require("config.markdown")

-- Run lua/config/cedar.lua, which marks Dogwood and Cedar schema files as
-- Cedar, so that syntax/cedar.lua colors them.
require("config.cedar")

-- Run lua/config/splitjoin.lua, which splits the items inside brackets onto
-- lines of their own and joins them back (gS).
require("config.splitjoin")

-- Run lua/config/tab.lua, which adds Tab, Shift-Tab, Enter and Ctrl-Space to
-- the completion menu.
require("config.tab")

-- Run lua/config/surround.lua, which adds, deletes and replaces quotes and
-- brackets around text (sa, sd, sr).
require("config.surround")

-- Run lua/config/format.lua, which adds :Format, to tidy the current file
-- with the project's own tools (Ruff, or ESLint and Prettier).
require("config.format")
