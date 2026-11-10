-- Your shortcuts. We store the function in a short name, "map".
-- Each line reads: map(mode, keys you press, what it does, optional details).
-- "n" means the shortcut works in normal mode.
-- <cmd>...<CR> means "run this command", as if you typed it after a colon.
local map = vim.keymap.set

-- Esc also clears the yellow highlights left behind by a search.
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Tap Space, then w, to save the file.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })

-- Tap Space, then e, to see the files in the current file's folder.
map("n", "<leader>e", "<cmd>Explore<CR>", { desc = "File explorer" })

-- Hold Ctrl and press h to move to the split on the left.
map("n", "<C-h>", "<C-w>h")

-- Hold Ctrl and press j to move to the split below.
map("n", "<C-j>", "<C-w>j")

-- Hold Ctrl and press k to move to the split above.
map("n", "<C-k>", "<C-w>k")

-- Hold Ctrl and press l to move to the split on the right.
map("n", "<C-l>", "<C-w>l")
