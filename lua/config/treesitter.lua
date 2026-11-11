
-- Syntax highlighting. Tree-sitter is a parser: it reads the code the way a
-- compiler does, so it can tell a function name from a variable, a class or a
-- parameter. Without it Neovim only guesses with simple patterns, which is why
-- so few colors showed up.

-- When vim.pack updates nvim-treesitter, update the parsers too, because each
-- plugin version expects matching parser versions. This has to be set up
-- before vim.pack.add below.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
      vim.cmd("TSUpdate")
    end
  end,
})

-- nvim-treesitter downloads the parsers and holds the rules that say which
-- piece of code gets which color. It needs: brew install tree-sitter-cli
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

-- Download and build a parser for each of these languages. This runs in the
-- background on the first start and does nothing once they are installed.
-- "tsx" is TypeScript with JSX, used in React files.
require("nvim-treesitter").install({
  "python",
  "typescript",
  "tsx",
  "javascript",
  "json",
  "yaml",
  "toml",
  "bash",
})

-- Each time a file is opened, turn tree-sitter highlighting on for it.
-- pcall means "try it, and ignore the error": a file type that has no parser
-- installed simply keeps the old highlighting.
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
