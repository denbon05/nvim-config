-- Your shortcuts. We store the function in a short name, "map".
-- Each line reads: map(mode, keys you press, what it does, optional details).
-- "n" means the shortcut works in normal mode.
-- <cmd>...<CR> means "run this command", as if you typed it after a colon.
local map = vim.keymap.set

-- Esc also clears the yellow highlights left behind by a search.
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- After a search, n and N jump to the next and previous match, and * searches
-- for the word under the cursor. Here each of them also runs zz, which
-- scrolls the line with the match to the middle of the window.
map("n", "n", "nzz", { desc = "Next match, mid-screen" })
map("n", "N", "Nzz", { desc = "Previous match, mid-screen" })
map("n", "*", "*zz", { desc = "Find the word under the cursor, mid-screen" })

-- Ctrl-o and Ctrl-i jump back and forward through the places you jumped
-- from, such as the line before a gd. Here they also run zz, so the place
-- you land on is in the middle of the window, like after gd.
map("n", "<C-o>", "<C-o>zz", { desc = "Jump back, mid-screen" })
map("n", "<C-i>", "<C-i>zz", { desc = "Jump forward, mid-screen" })
-- Most terminals send the same key for Tab and Ctrl-i, and Tab in Normal
-- mode jumps forward too. Map it the same way, so both keys behave alike.
map("n", "<Tab>", "<Tab>zz", { desc = "Jump forward, mid-screen" })

-- The first jump of a search, /text or ?text and then Enter, is centered too.
-- "c" means the shortcut works while typing on the command line at the
-- bottom. getcmdtype() tells what is being typed there: "/" or "?" for a
-- search, ":" for a command. Only a search gets zz added after its Enter.
-- expr = true means the function returns the keys to press.
map("c", "<CR>", function()
  local kind = vim.fn.getcmdtype()
  if kind == "/" or kind == "?" then
    return "<CR>zz"
  end
  return "<CR>"
end, { expr = true, desc = "Run the search and show the match mid-screen" })

-- A namespace is a label for the colors added below, so that they can be
-- removed again without touching any other highlighting.
local cheatsheet_keys = vim.api.nvim_create_namespace("cheatsheet_keys")

-- Color the keys in the lists of the cheatsheet, like the keys in its
-- sentences. buf is the number of the buffer that holds the cheatsheet.
local function color_cheatsheet_keys(buf)
  -- Remove the colors of the previous call, in case the file has changed.
  vim.api.nvim_buf_clear_namespace(buf, cheatsheet_keys, 0, -1)

  -- A list sits between two lines that start with three backticks.
  local in_list = false
  for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if line:match("^```") then
      in_list = not in_list
    elseif in_list then
      -- The keys are the text from the start of the line up to the first gap
      -- of two spaces. A line that continues a description starts with
      -- spaces, so it has no keys.
      local keys = line:match("^(%S.-)%s%s")
      if keys then
        -- Leave the star that marks my own shortcuts uncolored.
        keys = keys:gsub(" %*$", "")
        -- Paint the keys with the color of `code` in a sentence. Rows are
        -- counted from 0 here, which is why "row - 1" appears.
        vim.api.nvim_buf_set_extmark(buf, cheatsheet_keys, row - 1, 0, {
          end_col = #keys,
          hl_group = "@markup.raw.markdown_inline",
        })
      end
    end
  end
end

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

  -- Color the keys in the lists. 0 means the current buffer.
  color_cheatsheet_keys(0)

  -- In the cheatsheet only, q closes its window.
  map("n", "q", "<cmd>close<CR>", { buffer = true, desc = "Close the cheatsheet" })
end, { desc = "Open the cheatsheet" })

-- Tap Space, then z, to turn spell checking on or off in this window. The
-- letter is z because Neovim's spelling keys start with it: z= suggests a
-- fix, zg adds a word. vim.wo holds the settings of the current window.
map("n", "<leader>z", function()
  vim.wo.spell = not vim.wo.spell
  print("Spell checking " .. (vim.wo.spell and "on" or "off"))
end, { desc = "Toggle spell checking" })

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
