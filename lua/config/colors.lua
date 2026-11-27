
-- Colors. A color scheme decides which color each kind of text gets.

-- vscode.nvim copies the default light and dark themes of VS Code.
vim.pack.add({ "https://github.com/Mofiqul/vscode.nvim" })

-- More color schemes to try. They are only downloaded here; the one switched
-- on is chosen at the end of this file. To look through them, type
-- :FzfLua colorschemes and move up and down the list: each one is shown in
-- the file right away, Enter keeps it, Esc goes back to the old one.
--
-- Each has a dark and a light version. The plain name (catppuccin,
-- tokyonight, kanagawa, rose-pine, modus) follows the terminal like vscode
-- does; the names after it pick one version whatever the terminal is.
vim.pack.add({
  -- catppuccin: dark catppuccin-mocha, catppuccin-macchiato; light catppuccin-latte.
  -- The repository is called "nvim", so it gets a clearer folder name.
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  -- tokyonight: dark tokyonight-night, tokyonight-storm, tokyonight-moon;
  -- light tokyonight-day.
  "https://github.com/folke/tokyonight.nvim",
  -- kanagawa: dark kanagawa-wave, kanagawa-dragon; light kanagawa-lotus.
  "https://github.com/rebelot/kanagawa.nvim",
  -- rose-pine: dark rose-pine-main, rose-pine-moon; light rose-pine-dawn.
  -- The repository is called "neovim", so it gets a clearer folder name too.
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
  -- nightfox: dark nightfox, carbonfox, nordfox, duskfox, terafox;
  -- light dayfox, dawnfox. It has no name that follows the terminal.
  "https://github.com/EdenEast/nightfox.nvim",
  -- modus: dark modus_vivendi; light modus_operandi. The easiest to read.
  "https://github.com/miikanissi/modus-themes.nvim",
})

-- Paint added lines with a calmer green in the dark VS Code theme. The
-- theme's own green (#4B5632) is too saturated; #373D29 is the one VS Code
-- itself uses for added lines in its dark theme. The light theme and the
-- other color schemes keep their colors.
local function soften_added_lines()
  if vim.g.colors_name == "vscode" and vim.o.background == "dark" then
    vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#373D29" })
  end
end

-- Loading a color scheme resets every color, and Neovim loads it again when
-- the terminal switches between light and dark. So set the green after every
-- load. The autocommand is created first, so it covers the load below too.
vim.api.nvim_create_autocmd("ColorScheme", { callback = soften_added_lines })

-- terafox paints the Visual mode selection and added lines with the same
-- background (#293e40), so a selection on an added line can't be seen. Its
-- search matches, changed lines and cursor line are teal too, so the
-- selection gets a slate blue (#3d4263) that no other background uses.
local function recolor_selection()
  if vim.g.colors_name == "terafox" then
    vim.api.nvim_set_hl(0, "Visual", { bg = "#3d4263" })
  end
end

-- After every color scheme load, like the green above.
vim.api.nvim_create_autocmd("ColorScheme", { callback = recolor_selection })

-- Switch it on. terafox is dark only and stays dark in a light terminal too.
-- It has no light version; for light mode try dayfox (same family) or shine
-- (built into Neovim). To go back to a scheme that follows the terminal, put
-- "vscode" here.
vim.cmd.colorscheme("terafox")
