-- Tab, Shift-Tab, Enter and Ctrl-Space for the completion menu in Insert
-- mode, as in an IDE. Neovim's own keys keep working: Ctrl-n / Ctrl-p choose,
-- Ctrl-y accepts, Ctrl-e closes the menu.
local map = vim.keymap.set

-- expr = true, used below, means the function returns the keys to press.
-- That is how one key can do different things in different situations.

-- The keys that open the menu. If a language server that can suggest
-- completions works on this file, ask it. <Cmd>...<CR> runs a command
-- without leaving Insert mode. With no server, for example in a markdown
-- file, Ctrl-n suggests the words of the open files.
local function open_menu()
  local servers = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/completion" })
  if #servers > 0 then
    return "<Cmd>lua vim.lsp.completion.get()<CR>"
  end
  return "<C-n>"
end

-- Tab:
--   the menu is open                 -> the next item (Ctrl-n)
--   code with gaps is being filled   -> the next gap ("snippet": a server
--                                       can insert code with places to fill)
--   right after a letter, digit,     -> open the menu
--   _ or a dot
--   anywhere else                    -> a normal Tab, for indentation
map("i", "<Tab>", function()
  -- pumvisible() is 1 while the menu ("popup menu") is open.
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  end

  -- Neovim's own Tab jumps to the next gap of a snippet. This shortcut
  -- replaces it, so it does that job too.
  if vim.snippet.active({ direction = 1 }) then
    return "<Cmd>lua vim.snippet.jump(1)<CR>"
  end

  -- The character just before the cursor. col(".") is the cursor's column,
  -- counted from 1, so the one before it is col(".") - 1.
  local col = vim.fn.col(".") - 1
  local before = vim.fn.getline("."):sub(col, col)
  if not before:match("[%w_.]") then
    return "<Tab>"
  end
  return open_menu()
end, { expr = true, desc = "Next completion, or open the menu" })

-- Shift-Tab: the previous item while the menu is open, the previous gap of a
-- snippet, or else what Shift-Tab does anyway.
map("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  end
  if vim.snippet.active({ direction = -1 }) then
    return "<Cmd>lua vim.snippet.jump(-1)<CR>"
  end
  return "<S-Tab>"
end, { expr = true, desc = "Previous completion" })

-- Ctrl-Space: open the menu anywhere, also on an empty line or after a
-- space, where Tab makes an indent. The server then lists every name that
-- can be used there: variables, functions, modules and Python's own words.
-- Typing narrows the list. After a dot, such as helper8. it lists what that
-- object has, the same as the menu that opens by itself after a dot.
map("i", "<C-Space>", open_menu, { expr = true, desc = "Show all completions" })

-- Enter: accept the item picked with Tab, as Ctrl-y does. Only an accepted
-- item lets the server finish its job, such as adding a missing import.
-- complete_info() tells which item is picked: -1 means none. With the menu
-- open but nothing picked, Enter starts a new line as usual.
map("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 then
    return "<C-y>"
  end
  return "<CR>"
end, { expr = true, desc = "Accept the completion, or a new line" })
