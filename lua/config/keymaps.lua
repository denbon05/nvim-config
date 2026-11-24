-- Your shortcuts. We store the function in a short name, "map".
-- Each line reads: map(mode, keys you press, what it does, optional details).
-- "n" means the shortcut works in normal mode.
-- <cmd>...<CR> means "run this command", as if you typed it after a colon.
local map = vim.keymap.set

-- Esc also clears the yellow highlights left behind by a search.
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- ; and : swap places in Normal and Visual mode, so a command starts with ;
-- without Shift, and Shift-; repeats the last f or t jump that ; did before.
-- "x" is Visual mode. Keys typed on the command line itself don't change.
map({ "n", "x" }, ";", ":", { desc = "Start a command" })
map({ "n", "x" }, ":", ";", { desc = "Repeat the last f / t jump" })

-- The keys that scroll the cursor line a little above the middle of the
-- window, "high". See lua/config/center.lua for why not the middle.
-- <Cmd>...<CR> runs it after the jump, without leaving Normal mode.
local high = "<Cmd>lua require('config.center')()<CR>"

-- After a search, n and N jump to the next and previous match, and * searches
-- for the word under the cursor. Here each of them also scrolls the line with
-- the match high. A count still works: 3n jumps to the third match.
map("n", "n", "n" .. high, { desc = "Next match, shown high" })
map("n", "N", "N" .. high, { desc = "Previous match, shown high" })
map("n", "*", "*" .. high, { desc = "Find the word under the cursor, shown high" })

-- Ctrl-o and Ctrl-i jump back and forward through the places you jumped
-- from, such as the line before a gd. Here they also scroll the place you
-- land on high, like after gd.
map("n", "<C-o>", "<C-o>" .. high, { desc = "Jump back, shown high" })
map("n", "<C-i>", "<C-i>" .. high, { desc = "Jump forward, shown high" })
-- Most terminals send the same key for Tab and Ctrl-i, and Tab in Normal
-- mode jumps forward too. Map it the same way, so both keys behave alike.
map("n", "<Tab>", "<Tab>" .. high, { desc = "Jump forward, shown high" })

-- The first jump of a search, /text or ?text and then Enter, is shown high
-- too. "c" means the shortcut works while typing on the command line at the
-- bottom. getcmdtype() tells what is being typed there: "/" or "?" for a
-- search, ":" for a command. Only a search gets the scrolling after its Enter.
-- expr = true means the function returns the keys to press.
map("c", "<CR>", function()
  local kind = vim.fn.getcmdtype()
  if kind == "/" or kind == "?" then
    return "<CR>" .. high
  end
  return "<CR>"
end, { expr = true, desc = "Run the search and show the match high" })

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
        -- Leave the ★ that marks my own shortcuts uncolored.
        keys = keys:gsub(" ★$", "")
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

-- D in the file list (Space e): move to the macOS Trash, instead of deleting
-- for good as the file list's own D does. It takes the files marked with mf
-- if there are any, or else the lines from first to last: the cursor line,
-- or the lines selected with V. Folders go too, with all inside.
local function trash_in_file_list(first, last)
  -- The tree view (i) shows the files of several folders at once, and the
  -- name on a line doesn't say which folder it is in.
  if vim.w.netrw_liststyle == 3 then
    print("D doesn't work in the tree view: press i to switch the view")
    return
  end

  -- The folder the file list shows, and where the view is, to come back to.
  local dir = vim.b.netrw_curdir
  local view = vim.fn.winsaveview()

  -- The names of the files marked with mf in this file list. netrw#Expose
  -- reads one of the file list's own variables; it returns "n/a", not a
  -- list, when nothing is marked.
  local names = vim.fn["netrw#Expose"]("netrwmarkfilelist_" .. vim.fn.bufnr())
  local marked = type(names) == "table" and #names > 0
  if not marked then
    names = {}
    -- The lines above netrw_bannercnt are the help at the top, not files.
    for row = math.max(first, vim.w.netrw_bannercnt or 1), last do
      vim.api.nvim_win_set_cursor(0, { row, 0 })
      -- The file list's own function that reads the name on the cursor line.
      local name = vim.fn["netrw#Call"]("NetrwGetWord")
      if name ~= "./" and name ~= "../" then
        table.insert(names, name)
      end
    end
  end

  -- The full paths. The file list adds a sign after some names, which is
  -- not part of the name: / for a folder, @ for a link, * for a program.
  local paths, shown = {}, {}
  for _, name in ipairs(names) do
    local path = vim.fs.joinpath(dir, (name:gsub("[/@=|*]$", "")))
    table.insert(paths, path)
    -- The path as shown in the question: from the project folder, or ~.
    table.insert(shown, "  " .. vim.fn.fnamemodify(path, ":~:."))
  end
  vim.fn.winrestview(view)
  if #paths == 0 then
    return
  end

  -- Ask first, with No as the choice of Enter, like :Delete.
  local question = "Move to the Trash?\n" .. table.concat(shown, "\n")
  if vim.fn.confirm(question, "&Yes\n&No", 2) ~= 1 then
    return
  end

  -- trash, which comes with macOS, takes all the paths at once.
  local result = vim.system(vim.list_extend({ "trash" }, paths)):wait()
  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR)
  end

  -- Close the trashed files that are open in the background: not shown in
  -- a window and without unsaved changes. A file shown in a window stays,
  -- so no window closes under you.
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if vim.tbl_contains(paths, name) and vim.fn.bufwinid(buf) == -1 and not vim.bo[buf].modified then
      vim.api.nvim_buf_delete(buf, {})
    end
  end

  -- Clear the marks of this file list, as mF does. (The file list's own D
  -- uses another function, which misses the marks when the file list is the
  -- newest buffer.) Then read the folder again and go back to the same view.
  if marked then
    vim.fn["netrw#Call"]("NetrwUnmarkList", vim.fn.bufnr(), dir)
  end
  vim.fn["netrw#Call"]("NetrwRefresh", 1, vim.fn["netrw#Call"]("NetrwBrowseChgDir", 1, "./", 0))
  vim.fn.winrestview(view)
end

-- The file list (Space e) has shortcuts of its own, and there Ctrl-l reads
-- the folder again, to show files made outside Neovim. The file list leaves
-- Ctrl-l alone when another key does that, so F5 does it here, and Ctrl-l
-- moves to the split on the right in the file list too. D moves to the Trash.
-- The FileType event runs when a file list opens. buffer = args.buf makes
-- the keys work in that file list only.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function(args)
    -- <Plug>NetrwRefresh is the file list's own refresh. remap = true lets
    -- F5 run it.
    map("n", "<F5>", "<Plug>NetrwRefresh", {
      buffer = args.buf,
      remap = true,
      desc = "Refresh the file list",
    })
    -- The file list may have taken Ctrl-l before this runs: take it back.
    map("n", "<C-l>", "<C-w>l", { buffer = args.buf })

    -- D, and the Delete key (fn-Backspace), move to the Trash. See
    -- trash_in_file_list above.
    for _, key in ipairs({ "D", "<Del>" }) do
      -- In Normal mode: the marked files, or the file on the cursor line.
      map("n", key, function()
        local row = vim.fn.line(".")
        trash_in_file_list(row, row)
      end, { buffer = args.buf, desc = "Move to the Trash" })

      -- In Visual mode (V): the selected lines. line("v") is the line where
      -- the selection started, line(".") the cursor's.
      map("x", key, function()
        local first, last = vim.fn.line("v"), vim.fn.line(".")
        if first > last then
          first, last = last, first
        end
        -- Leave Visual mode. "\27" is Esc.
        vim.cmd("normal! \27")
        trash_in_file_list(first, last)
      end, { buffer = args.buf, desc = "Move the selected files to the Trash" })
    end
  end,
})

-- The list at the bottom that grr and :vimgrep fill ("quickfix" list) has
-- two keys of its own. Enter keeps working as before: it jumps to the place
-- and leaves the list open, for ]q and [q.
-- o ("open") jumps to the place on the cursor line and closes the list.
-- q closes the list and stays where I am.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(args)
    map("n", "o", function()
      -- The same window type shows a "location list", the list of one
      -- window: its commands are :ll and :lclose instead of :cc and :cclose.
      local is_location_list = vim.fn.win_gettype() == "loclist"
      -- The dot is the cursor line: :.cc jumps to the place on it. The
      -- jump moves the cursor into the file's window. :lclose closes the
      -- list of the window it runs in, which is that window now.
      vim.cmd(is_location_list and ".ll" or ".cc")
      vim.cmd(is_location_list and "lclose" or "cclose")
      -- The window has grown back to full height: show the line high.
      require("config.center")()
    end, { buffer = args.buf, desc = "Jump to the place and close the list" })
    map("n", "q", "<Cmd>close<CR>", { buffer = args.buf, desc = "Close the list" })
  end,
})

-- Tap Space, then y, then p, to copy the full path of the current file
-- ("yank path"). expand("%:p") gives the path: % is the current file and :p
-- makes it a full path. setreg("+", ...) puts it into the macOS clipboard.
-- The path is also shown at the bottom, so you can see what was copied.
map("n", "<leader>yp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("Copied: " .. path)
end, { desc = "Copy file path" })

-- Type :Delete and press Enter to move the file you are in to the macOS
-- Trash and close it. It asks first. Finder's "Put Back" restores it.
vim.api.nvim_create_user_command("Delete", function()
  -- The full path of the file in this window. It is empty in a window that
  -- shows no file, such as a new unsaved one.
  local path = vim.api.nvim_buf_get_name(0)
  -- filereadable is 0 for a file that was never saved, and for a folder,
  -- such as the one the file list (Space e) shows.
  if path == "" or vim.fn.filereadable(path) == 0 then
    print("This window shows no file on disk")
    return
  end

  -- confirm shows the question with the choices and returns the number of
  -- the one picked: 1 is Yes. The last argument makes No the choice of
  -- Enter, so a hasty Enter changes nothing. Esc returns 0, also nothing.
  local name = vim.fn.expand("%")
  if vim.fn.confirm("Move " .. name .. " to the Trash?", "&Yes\n&No", 2) ~= 1 then
    return
  end

  -- trash is a command that comes with macOS. vim.system starts it
  -- directly, without a shell, so a path with spaces is safe.
  local result = vim.system({ "trash", path }):wait()
  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR)
    return
  end

  -- Close the file. ! drops its unsaved changes too: the file is gone.
  vim.cmd("bdelete!")
  print("Moved to the Trash: " .. name)
end, { desc = "Move the current file to the Trash" })

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
