
-- Plugins. vim.pack is the plugin manager built into Neovim 0.12.
-- On the first start it asks before downloading anything: press y.
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

-- Load fzf-lua and start it with its default settings.
local fzf = require("fzf-lua")
fzf.setup({})

-- Tap Space, then f, to find a file by typing part of its name (like Cmd+P).
vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Find files" })

-- Tap Space, then Shift-f, for the same search including the files git
-- ignores, such as .env. The big generated folders stay left out.
vim.keymap.set("n", "<leader>F", function()
  fzf.files({
    -- Tell fd not to read .gitignore.
    no_ignore = true,
    -- The default fd options, plus the folders to skip.
    fd_opts = "--color=never --type f --type l --exclude .git --exclude .venv"
      .. " --exclude node_modules --exclude __pycache__ --exclude '.*_cache'",
  })
end, { desc = "Find files, ignored too" })

-- Tap Space, then /, to search for text in every file of the project.
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Search text" })

-- Tap Space, then b, to pick one of the open files (buffers) from a list.
vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Open buffers" })

-- Tap Space, then g, to list the files changed since the last commit ("git").
-- The list is on the left and the diff of the selected file is on the right.
-- Shift-Down and Shift-Up scroll the diff, and Enter opens the file.
vim.keymap.set("n", "<leader>g", function()
  fzf.git_status({
    winopts = {
      -- Use the whole screen.
      fullscreen = true,
      preview = {
        -- Put the diff on the right and give it 70% of the width,
        -- which leaves a narrow column for the file list.
        layout = "horizontal",
        horizontal = "right:70%",
        -- Continue a long line on the next row. Without this it is cut off.
        wrap = true,
      },
    },
  })
end, { desc = "Git changes" })
