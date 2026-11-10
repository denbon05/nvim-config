-- Editor settings. "vim.o" is how Lua reaches Neovim's options.
-- We store it in a short name, "o", to save typing below.
local o = vim.o

-- Show line numbers in the left margin.
o.number = true

-- Show every other line's DISTANCE from the cursor instead of its real number.
-- If a line you want shows 5, then typing 5j jumps straight down to it.
-- (j means "down", k means "up", and a number in front repeats the command.)
o.relativenumber = true

-- Always keep a narrow column on the far left for error markers.
-- Without this, the text shifts sideways when a marker appears.
o.signcolumn = "yes"

-- Highlight the line the cursor is on, so it's easy to find.
o.cursorline = true

-- Keep at least 8 lines visible above and below the cursor when scrolling.
o.scrolloff = 8

-- Make search ignore upper and lower case...
o.ignorecase = true

-- ...unless your search contains a capital letter. Then case matters.
o.smartcase = true

-- Pressing Tab inserts spaces rather than a tab character.
o.expandtab = true

-- One level of indentation is 2 spaces. Python files automatically use 4.
o.shiftwidth = 2

-- A tab character already in a file is displayed 2 columns wide.
o.tabstop = 2

-- A new side-by-side split opens on the right.
o.splitright = true

-- A new top-and-bottom split opens below.
o.splitbelow = true

-- Remember undo history after you close a file.
o.undofile = true

-- Share copy and paste with macOS. Note that deleting text also copies it.
o.clipboard = "unnamedplus"
