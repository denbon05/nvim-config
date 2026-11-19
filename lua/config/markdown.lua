-- Readable markdown. render-markdown draws a markdown file the way it will
-- look: headings get a colored background and an icon, list dashes become
-- bullets, [ ] and [x] become checkboxes, tables get borders, and code blocks
-- get a background. The symbols around the text, such as ** and `, are hidden.
-- The file itself does not change: it is only drawn differently.
--
-- The line with the cursor stays raw, so it can be edited as usual. In Insert
-- mode the whole file is raw.
--
-- It reads the file with the markdown parsers of tree-sitter, which are
-- installed in lua/config/treesitter.lua, together with the html parser (for
-- tags and comments) and the latex one (for math). Math between $ signs is
-- turned into Unicode text by utftex, from the Brewfile: $x^2$ shows as x².

-- Icons. mini.icons knows an icon for each file type and language, and
-- render-markdown shows it next to the language name of a code block. The
-- icons come from a Nerd Font, which the terminal needs (see the README).
vim.pack.add({ "https://github.com/nvim-mini/mini.icons" })
require("mini.icons").setup({})

vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

-- Load render-markdown with its default settings. It works on markdown files
-- only, so the code files stay as they are.
require("render-markdown").setup({})

-- The background of the heading lines. The vscode theme paints them all a dark
-- gray, so the blue and red heading text is hard to read on them in the light
-- theme. Instead, give each heading a faint tint of its own color: pale blue
-- behind a blue heading in the light theme, deep blue in the dark one.

-- Mix two colors, given as numbers like 0xRRGGBB. amount is how much of the
-- first one goes in: 0.15 means 15% of it and 85% of the second one.
local function mix(color, base, amount)
  local result = 0
  -- Mix each of red, green and blue separately. shift is the position of that
  -- part in the number: red is at 16, green at 8, blue at 0.
  for _, shift in ipairs({ 16, 8, 0 }) do
    local a = math.floor(color / 2 ^ shift) % 256
    local b = math.floor(base / 2 ^ shift) % 256
    result = result + math.floor(a * amount + b * (1 - amount) + 0.5) * 2 ^ shift
  end
  return result
end

local function tint_headings()
  local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
  -- Without a background color (a transparent terminal), there is nothing to
  -- mix with, so the theme's colors stay.
  if not normal_bg then
    return
  end
  for level = 1, 6 do
    -- RenderMarkdownH1 holds the text color of a level 1 heading, and
    -- RenderMarkdownH1Bg the background of its line.
    local text = vim.api.nvim_get_hl(0, { name = "RenderMarkdownH" .. level, link = false })
    if text.fg then
      vim.api.nvim_set_hl(0, "RenderMarkdownH" .. level .. "Bg", {
        bg = mix(text.fg, normal_bg, 0.15),
        bold = true,
      })
    end
  end
end

-- Loading a color scheme resets the colors, and Neovim loads it again when the
-- terminal switches between light and dark, so tint after every load. The
-- scheme was already loaded once in lua/config/colors.lua, so tint now too.
vim.api.nvim_create_autocmd("ColorScheme", { callback = tint_headings })
tint_headings()

-- Tap Space, then m, to switch between the drawn and the raw markdown, for
-- example to see exactly which symbols a line has. It switches only the file
-- I am in, so the cheatsheet and other markdown files stay drawn.
vim.keymap.set("n", "<leader>m", "<cmd>RenderMarkdown buf_toggle<CR>", { desc = "Toggle markdown view" })

-- Preview in the browser. markdown-preview shows the file as a web page, the
-- way GitHub draws it: with images, and with mermaid diagrams drawn as real
-- diagrams, which the terminal can't do. The page follows the edits as I type
-- and scrolls along with the cursor.

-- The plugin runs a small web server, a program it downloads from its GitHub
-- releases into its own folder. When vim.pack installs or updates the plugin,
-- download that program again. This has to be set up before vim.pack.add.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local kind = ev.data.kind
    if ev.data.spec.name == "markdown-preview.nvim" and (kind == "install" or kind == "update") then
      -- The download function is part of the plugin, so load the plugin first
      -- if it is not loaded yet.
      if not ev.data.active then
        vim.cmd.packadd("markdown-preview.nvim")
      end
      vim.fn["mkdp#util#install"]()
    end
  end,
})

vim.pack.add({ "https://github.com/iamcco/markdown-preview.nvim" })

-- Keep the page open when I switch to another file. By default the plugin
-- closes it as soon as I leave the markdown file, for example to look
-- something up in the code. Space p closes it.
vim.g.mkdp_auto_close = 0

-- Print the address of the page, for example to open it in another browser.
vim.g.mkdp_echo_preview_url = 1

-- Tap Space, then p, to open the preview of the markdown file in the browser,
-- or to close it. The plugin's commands exist only in markdown files, so the
-- shortcut is set for each markdown file when it opens.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    vim.keymap.set("n", "<leader>p", "<cmd>MarkdownPreviewToggle<CR>", {
      buffer = ev.buf,
      desc = "Preview markdown in the browser",
    })
  end,
})
