-- Add, delete and replace the quotes or brackets around a piece of text.
-- Neovim has no keys for this, so mini.surround adds them. They all start
-- with s, for "surround".
vim.pack.add({ "https://github.com/nvim-mini/mini.surround" })

-- Load mini.surround with its default settings. In Normal mode:
--   sa, a motion, a character   Add: saiw" puts " " around the word
--                               ("surround add inner word").
--   v, select, sa, a character  Add around the selection.
--   sd, a character             Delete: sd" removes the quotes around the
--                               cursor.
--   sr, old, new                Replace: sr)] turns ( ) into [ ].
-- ) and ] add the brackets tight: (word). ( and [ add a space inside them:
-- ( word ). s on its own still deletes a character and starts typing, after
-- a short wait to see whether a, d or r follows.
require("mini.surround").setup({})
