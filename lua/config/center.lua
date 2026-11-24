-- Scroll so the line with the cursor sits a little above the middle of the
-- window. Every jump in this config ends with this: n, N, *, a search,
-- Ctrl-o, Ctrl-i, gd, gf on a heading, Ctrl-n and Ctrl-p.
--
-- Why not the middle, as zz does: when a pane opens at the bottom (the list
-- of grr, a terminal), the window gets shorter from below and a line in the
-- middle ends up low or hidden. A line higher up stays in view.
--
-- Other files use it as: require("config.center")()

-- Where the line goes, as a share of the window height counted from the top.
-- 0.5 is the middle (like zz); 0.3 is 20% of the height above the middle.
local SPOT = 0.3

return function()
  -- Start from the middle, as zz does. "normal!" runs Neovim's own zz, not
  -- the animated one of neoscroll.
  vim.cmd("normal! zz")

  -- The screen row to aim for, counted from 1 at the top of the window.
  local target = math.floor(vim.api.nvim_win_get_height(0) * SPOT) + 1

  -- winline() is the screen row the cursor is on now. Ctrl-e scrolls the
  -- text up by one line, which moves the cursor's row up. Repeat until the
  -- row is high enough. Near the start of a file zz can't reach the middle,
  -- so the row is already high enough and nothing scrolls.
  while vim.fn.winline() > target do
    local before = vim.fn.winsaveview()
    -- "\5" is Ctrl-e.
    vim.cmd("normal! \5")
    -- scrolloff keeps some lines above the cursor. When the cursor gets too
    -- close to the top, Neovim moves it down a line instead. Undo that step
    -- and stop, so the cursor stays where the jump put it. Stop too if
    -- nothing scrolled.
    local after = vim.fn.winsaveview()
    if after.lnum ~= before.lnum or after.topline == before.topline then
      vim.fn.winrestview(before)
      break
    end
  end
end
