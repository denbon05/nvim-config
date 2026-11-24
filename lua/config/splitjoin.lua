-- Split the items inside brackets onto lines of their own, and join them
-- back. J joins the next line onto this one, but Neovim has no key for the
-- other way round. mini.splitjoin adds one key that does both.
vim.pack.add({ "https://github.com/nvim-mini/mini.splitjoin" })

-- Load mini.splitjoin with its default settings. Tap g, then Shift-s ("go
-- Split"), with the cursor inside ( ), [ ] or { }: the items, separated by
-- commas, go onto lines of their own, one indent deeper. gS on them again
-- puts them back on one line. It reads brackets and commas only, so it
-- works the same in every language.
require("mini.splitjoin").setup({})
