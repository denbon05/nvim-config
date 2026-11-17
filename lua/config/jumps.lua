-- [m and ]m jump to the name of a function, method or class. Tree-sitter
-- (see treesitter.lua) finds the names, so the same keys work in Python,
-- JavaScript and TypeScript. On the name, gd, grr, K and grn work right away.
-- In other files [m and ]m keep their built-in meaning.

-- Neovim's own settings for Python give each Python file its own [m and ]m
-- (and ]], [[, ]M, [M), which would win over the shortcuts below. This turns
-- them off.
vim.g.no_python_maps = true

-- A tree-sitter query lists the kinds of code to look for. In each line,
-- "name:" is the part of that code that holds its name, (_) accepts any kind
-- of name, and @name marks it as the place to jump to.
local js_names = [[
  (function_declaration name: (_) @name)
  (generator_function_declaration name: (_) @name)
  (class_declaration name: (_) @name)
  (method_definition name: (_) @name)
  (variable_declarator
    name: (identifier) @name
    value: [(arrow_function) (function_expression)])
]]

-- The query for each language. "tsx" is TypeScript with JSX.
local name_queries = {
  -- def and async def, and class.
  python = [[
    (function_definition name: (_) @name)
    (class_definition name: (_) @name)
  ]],
  -- function, function*, class, a method, and const f = () => or
  -- const f = function.
  javascript = js_names,
  -- The same, plus abstract classes, which only TypeScript has.
  typescript = js_names .. "(abstract_class_declaration name: (_) @name)",
  tsx = js_names .. "(abstract_class_declaration name: (_) @name)",
}

-- Return the positions of every name in the current file, from top to
-- bottom, as { line, column }. Return nothing if this language has no query
-- above or no tree-sitter parser.
local function find_names()
  -- The tree-sitter language of this file type, such as "tsx" for
  -- typescriptreact.
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  if not lang or not name_queries[lang] then
    return nil
  end
  -- error = false: return nothing instead of failing when the parser is
  -- missing.
  local parser = vim.treesitter.get_parser(0, lang, { error = false })
  if not parser then
    return nil
  end

  -- The tree of the whole file, and the query run over it.
  local root = parser:parse()[1]:root()
  local query = vim.treesitter.query.parse(lang, name_queries[lang])
  local names = {}
  -- The captures come in the order of the file.
  for _, node in query:iter_captures(root, 0) do
    -- Tree-sitter counts lines from 0, the cursor from 1.
    local row, col = node:start()
    table.insert(names, { row + 1, col })
  end
  return names
end

-- Return whether position a comes before position b.
local function is_before(a, b)
  return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
end

-- Jump to a name below the cursor (is_down true) or above it. A count before
-- the keys skips that many names: 2]m.
local function jump_to_name(is_down)
  -- The count, 1 if none was typed. Read it first: normal! below resets it.
  local count = vim.v.count1
  local names = find_names()
  if not names then
    -- No query for this language: run the built-in [m or ]m.
    vim.cmd("normal! " .. count .. (is_down and "]m" or "[m"))
    return
  end

  -- The names in the direction of the jump, from top to bottom.
  local cursor = vim.api.nvim_win_get_cursor(0)
  local names_ahead = {}
  for _, name in ipairs(names) do
    if (is_down and is_before(cursor, name)) or (not is_down and is_before(name, cursor)) then
      table.insert(names_ahead, name)
    end
  end

  -- Going down, the nearest name is the first one, going up the last one.
  -- math.max and math.min stop at the last name when the count is too big.
  local target
  if is_down then
    target = names_ahead[math.min(count, #names_ahead)]
  else
    target = names_ahead[math.max(#names_ahead - count + 1, 1)]
  end
  if target then
    -- Remember this place, so that Ctrl-o comes back to it.
    vim.cmd("normal! m'")
    vim.api.nvim_win_set_cursor(0, target)
  end
end

-- [m jumps up to the name of the function or class the cursor is in, ]m down
-- to the next one.
vim.keymap.set("n", "[m", function()
  jump_to_name(false)
end, { desc = "Name of the function or class above" })

vim.keymap.set("n", "]m", function()
  jump_to_name(true)
end, { desc = "Name of the next function or class" })
