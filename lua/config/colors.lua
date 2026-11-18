
-- Colors. A color scheme decides which color each kind of text gets.

-- vscode.nvim copies the default light and dark themes of VS Code.
vim.pack.add({ "https://github.com/Mofiqul/vscode.nvim" })

-- Paint added lines with a calmer green in the dark theme. The theme's own
-- green (#4B5632) is too saturated; #373D29 is the one VS Code itself uses for
-- added lines in its dark theme. The light theme keeps its colors.
local function soften_added_lines()
  if vim.o.background == "dark" then
    vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#373D29" })
  end
end

-- Loading a color scheme resets every color, and Neovim loads it again when
-- the terminal switches between light and dark. So set the green after every
-- load. The autocommand is created first, so it covers the load below too.
vim.api.nvim_create_autocmd("ColorScheme", { callback = soften_added_lines })

-- Switch it on. It reads the 'background' option, which Neovim sets from the
-- terminal: a light iTerm gives the light theme, a dark iTerm gives the dark one.
vim.cmd.colorscheme("vscode")
