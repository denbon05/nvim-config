
-- Plugins. vim.pack is the plugin manager built into Neovim 0.12.
-- On the first start it asks before downloading anything: press y.
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

-- Load fzf-lua and start it with its default settings.
local fzf = require("fzf-lua")
fzf.setup({})

-- Tap Space, then f, to find a file by typing part of its name (like Cmd+P).
vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Find files" })

-- Tap Space, then /, to search for text in every file of the project.
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Search text" })

-- Tap Space, then b, to pick one of the open files (buffers) from a list.
vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Open buffers" })

-- Tap Space, then g, to list the files changed since the last commit ("git").
-- The right side shows what changed in the selected file. Shift-Down and
-- Shift-Up scroll that side, and Enter opens the file.
vim.keymap.set("n", "<leader>g", fzf.git_status, { desc = "Git changes" })
