-- Your shortcuts. We store the function in a short name, "map".
-- Each line reads: map(mode, keys you press, what it does, optional details).
-- "n" means the shortcut works in normal mode.
-- <cmd>...<CR> means "run this command", as if you typed it after a colon.
local map = vim.keymap.set

-- Esc also clears the yellow highlights left behind by a search.
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Tap Space, then ?, to open the cheatsheet with every shortcut, on the right.
-- stdpath("config") is the folder of this config, ~/.config/nvim.
map("n", "<leader>?", function()
  vim.cmd.vsplit(vim.fn.stdpath("config") .. "/CHEATSHEET.md")

  -- Hide the line numbers and the marker column in this window only.
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = "no"

  -- Hide the markdown symbols, such as the backticks around a key.
  vim.opt_local.conceallevel = 2

  -- Continue a long line on the next row, breaking it between words.
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true

  -- In the cheatsheet only, q closes its window.
  map("n", "q", "<cmd>close<CR>", { buffer = true, desc = "Close the cheatsheet" })
end, { desc = "Open the cheatsheet" })

-- Tap Space, then w, to save the file.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })

-- Tap Space, then e, to show or hide the file list on the left.
map("n", "<leader>e", "<cmd>20Lexplore<CR>", { desc = "File explorer" })

-- Tap Space, then v, to split the window in two, side by side ("vertical").
-- The new window opens on the right and shows the same file.
map("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "Split side by side" })

-- Hold Ctrl and press h to move to the split on the left.
map("n", "<C-h>", "<C-w>h")

-- Hold Ctrl and press j to move to the split below.
map("n", "<C-j>", "<C-w>j")

-- Hold Ctrl and press k to move to the split above.
map("n", "<C-k>", "<C-w>k")

-- Hold Ctrl and press l to move to the split on the right.
map("n", "<C-l>", "<C-w>l")

-- Tap Space, then y, then p, to copy the full path of the current file
-- ("yank path"). expand("%:p") gives the path: % is the current file and :p
-- makes it a full path. setreg("+", ...) puts it into the macOS clipboard.
-- The path is also shown at the bottom, so you can see what was copied.
map("n", "<leader>yp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("Copied: " .. path)
end, { desc = "Copy file path" })

-- The line that pauses a program for debugging, for each file type.
local breakpoints = {
  python = "breakpoint()",
  javascript = "debugger;",
  javascriptreact = "debugger;",
  typescript = "debugger;",
  typescriptreact = "debugger;",
}

-- Tap Space, then d, to add a breakpoint line above the cursor line, with the
-- same indentation. Tap it again, on that line or the one below it, to remove it.
map("n", "<leader>d", function()
  -- vim.bo.filetype is the type of the current file, such as "python".
  local statement = breakpoints[vim.bo.filetype]
  if not statement then
    print("No breakpoint line for file type: " .. vim.bo.filetype)
    return
  end

  -- row is the cursor's line number. Lines are counted from 1 here, but
  -- get_lines and set_lines count from 0, which is why "row - 1" appears below.
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  local line_above = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1] or ""

  if vim.trim(line) == statement then
    -- The cursor is on a breakpoint: remove this line.
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, {})
  elseif vim.trim(line_above) == statement then
    -- The breakpoint is right above the cursor: remove that line.
    vim.api.nvim_buf_set_lines(0, row - 2, row - 1, false, {})
  else
    -- No breakpoint here: insert one above, copying this line's indentation.
    local indent = line:match("^%s*")
    vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { indent .. statement })
  end
end, { desc = "Toggle breakpoint line" })
