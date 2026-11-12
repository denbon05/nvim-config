
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
