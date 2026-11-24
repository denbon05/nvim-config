
-- Git changes inside the file itself. mini.diff compares the text on screen
-- with the version git has staged (or the last commit, if nothing is staged),
-- so a file that is fully staged shows no changes.
vim.pack.add({ "https://github.com/nvim-mini/mini.diff" })

-- Load mini.diff and start it with its default settings. From now on the line
-- numbers of added, changed and deleted lines are colored in every file.
local diff = require("mini.diff")
diff.setup({})

-- The "overlay" is the detailed view: deleted lines appear above the place
-- they were removed from, and added lines get a colored background, like the
-- inline diff of VS Code. This remembers whether I switched it on.
local overlay_on = false

-- Make one file's overlay match overlay_on. get_buf_data returns nothing for
-- a file mini.diff doesn't track, such as a help page, so those are skipped.
local function sync_overlay(buf)
  local data = diff.get_buf_data(buf)
  if data and data.overlay ~= overlay_on then
    diff.toggle_overlay(buf)
  end
end

-- Tap Space, then o, to show or hide the overlay in every open file.
vim.keymap.set("n", "<leader>o", function()
  overlay_on = not overlay_on
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    sync_overlay(buf)
  end
  print("Diff overlay " .. (overlay_on and "on" or "off"))
end, { desc = "Toggle diff overlay" })

-- mini.diff sends this event each time it has compared a file, which includes
-- the moment a file is opened. That makes a newly opened file follow overlay_on.
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniDiffUpdated",
  callback = function(ev)
    sync_overlay(ev.buf)
  end,
})

-- Scroll so that the change under the cursor is fully on screen. A "hunk" is
-- one change: a group of neighbouring added, changed or deleted lines.
local function show_whole_change()
  local data = diff.get_buf_data(0)
  if not data then
    return
  end

  -- cursor is { line, column }. It is restored below, after the scrolling.
  local cursor = vim.api.nvim_win_get_cursor(0)
  for _, hunk in ipairs(data.hunks) do
    -- The first and last line of this change. A change that only deletes
    -- lines has no lines of its own (buf_count is 0), so it counts as one.
    local first = math.max(hunk.buf_start, 1)
    local last = first + math.max(hunk.buf_count, 1) - 1

    if first <= cursor[1] and cursor[1] <= last then
      -- The rows left for the change once scrolloff keeps its lines visible
      -- above and below the cursor.
      local free_rows = vim.api.nvim_win_get_height(0) - 2 * vim.o.scrolloff

      if last - first + 1 <= free_rows then
        -- The change fits: put its middle line a little above the middle of
        -- the window, like the other jumps.
        vim.api.nvim_win_set_cursor(0, { math.floor((first + last) / 2), 0 })
        require("config.center")()
        -- A tall change can now start above the lines scrolloff keeps free
        -- at the top. Then scroll its first line to the top instead (zt),
        -- which leaves room for all of it. line("w0") is the first line on
        -- screen.
        if first < vim.fn.line("w0") + vim.o.scrolloff then
          vim.api.nvim_win_set_cursor(0, { first, 0 })
          vim.cmd("normal! zt")
        end
        -- Move the cursor back to where it was.
        vim.api.nvim_win_set_cursor(0, cursor)
      else
        -- The change is taller than the window: show as much of it as
        -- possible by scrolling its first line to the top (zt).
        vim.cmd("normal! zt")
      end
      return
    end
  end
end

-- Hold Ctrl and press n to jump to the next change, or p for the previous
-- one, and scroll so the whole change is visible. Without these shortcuts
-- Ctrl-n and Ctrl-p only repeat j and k. mini.diff's own ]h and [h still
-- work, but they don't scroll.
vim.keymap.set("n", "<C-n>", function()
  diff.goto_hunk("next")
  show_whole_change()
end, { desc = "Next change, fully visible" })

vim.keymap.set("n", "<C-p>", function()
  diff.goto_hunk("prev")
  show_whole_change()
end, { desc = "Previous change, fully visible" })

-- Tap Space, then s, to stage the whole file you are in ("stage"), the same
-- as Left in the Space g list. A new file is staged too.
vim.keymap.set("n", "<leader>s", function()
  -- The full path of the file in this window. It is empty in a window that
  -- shows no file, such as a new unsaved one.
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    print("This window shows no file")
    return
  end

  -- Save the file if it has unsaved changes, so that what gets staged is
  -- what you see.
  vim.cmd("update")

  -- Run "git add" in the file's folder and wait until it finishes.
  -- vim.system starts git directly, without a shell, so a path with spaces
  -- is safe. "--" tells git that what follows is a file name.
  local git_add = vim.system({ "git", "add", "--", path }, { cwd = vim.fs.dirname(path) }):wait()
  if git_add.code == 0 then
    -- mini.diff notices the staging by itself and removes the colors from
    -- the line numbers. "%" is the file's path as shown in the status line.
    print("Staged " .. vim.fn.expand("%"))
  else
    -- Show git's own message, such as "not a git repository".
    vim.notify(git_add.stderr, vim.log.levels.ERROR)
  end
end, { desc = "Stage the current file" })

-- Type :Restore and press Enter to throw away the unstaged changes of the
-- file you are in, and its unsaved ones. The staged changes stay. It asks
-- first, because the changes can't be brought back. Ctrl-x in the Space g
-- list throws away the staged ones too.
vim.api.nvim_create_user_command("Restore", function()
  -- The full path of the file in this window. It is empty in a window that
  -- shows no file, such as a new unsaved one.
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    print("This window shows no file")
    return
  end

  -- confirm shows the question with the choices and returns the number of
  -- the one picked: 1 is Yes. The last argument makes No the choice of
  -- Enter, so a hasty Enter changes nothing. Esc returns 0, also nothing.
  local question = "Throw away the unstaged changes of " .. vim.fn.expand("%") .. "?"
  if vim.fn.confirm(question, "&Yes\n&No", 2) ~= 1 then
    return
  end

  -- Run "git restore" in the file's folder and wait until it finishes. It
  -- writes the staged version of the file back to disk, or the last commit
  -- if nothing is staged. "--" tells git that what follows is a file name.
  local git_restore = vim.system({ "git", "restore", "--", path }, { cwd = vim.fs.dirname(path) }):wait()
  if git_restore.code == 0 then
    -- The file on disk changed: read it again and drop the text on screen.
    vim.cmd("edit!")
    print("Restored " .. vim.fn.expand("%"))
  else
    -- Show git's own message, such as "did not match any file(s) known to
    -- git" for a new file git doesn't know yet.
    vim.notify(git_restore.stderr, vim.log.levels.ERROR)
  end
end, { desc = "Throw away the unstaged changes of the current file" })

-- Overlay colors for a changed line: the old text red, the new text green,
-- the same as deleted and added lines. By default the color scheme paints
-- both of them red, so old and new text are hard to tell apart.
local function set_overlay_colors()
  -- The old version of a changed line, shown above the new one.
  vim.api.nvim_set_hl(0, "MiniDiffOverChange", { link = "DiffDelete" })
  vim.api.nvim_set_hl(0, "MiniDiffOverContext", { link = "DiffDelete" })
  -- The new version of a changed line, which is the real line of the file.
  vim.api.nvim_set_hl(0, "MiniDiffOverChangeBuf", { link = "DiffAdd" })
  vim.api.nvim_set_hl(0, "MiniDiffOverContextBuf", { link = "DiffAdd" })
end

set_overlay_colors()

-- Switching the color scheme resets every color, so set these again after it.
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_overlay_colors })
