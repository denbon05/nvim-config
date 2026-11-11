
-- Colors. A color scheme decides which color each kind of text gets.

-- vscode.nvim copies the default light and dark themes of VS Code.
vim.pack.add({ "https://github.com/Mofiqul/vscode.nvim" })

-- Switch it on. It reads the 'background' option, which Neovim sets from the
-- terminal: a light iTerm gives the light theme, a dark iTerm gives the dark one.
vim.cmd.colorscheme("vscode")
