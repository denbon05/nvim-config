-- gf opens the file whose path is under the cursor. In a markdown file a link
-- can also name a heading after #, as in docs/setup.md#install, or just
-- #install for a heading of the same file. There gf opens the file and puts
-- the cursor on that heading. In other files gf keeps its built-in meaning.

-- The anchor GitHub makes from a heading: lowercase, each space becomes a
-- hyphen, and every character that is not a letter, a digit, _ or - is
-- dropped. "Why it failed: retries" becomes "why-it-failed-retries".
local function heading_anchor(heading)
  local anchor = {}
  -- split(text, "\zs") cuts the text into single characters, so that letters
  -- of any alphabet stay whole.
  for _, char in ipairs(vim.fn.split(vim.fn.tolower(heading), [[\zs]])) do
    if char == " " then
      table.insert(anchor, "-")
    -- charclass() is 2 for letters, digits and _ of any alphabet.
    elseif char == "-" or vim.fn.charclass(char) == 2 then
      table.insert(anchor, char)
    end
  end
  return table.concat(anchor)
end

-- The line number of the heading with this anchor in the current file, or
-- nil. With two headings of the same text, the first one wins.
local function find_heading(anchor)
  -- Lines between ``` are code, where # starts a comment, not a heading.
  local in_code = false
  for row, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:match("^%s*```") then
      in_code = not in_code
    elseif not in_code then
      -- A heading starts with # signs and a space. # signs at its end, which
      -- markdown allows, are not part of the text.
      local heading = line:match("^#+%s+(.-)%s*#*%s*$")
      if heading and heading_anchor(heading) == anchor then
        return row
      end
    end
  end
end

-- What gf does in a markdown file.
local function follow_link()
  -- <cfile> is the path under the cursor, the same one gf takes.
  local target = vim.fn.expand("<cfile>")
  local path, anchor = target:match("^(.-)#(.+)$")

  if not anchor then
    -- No heading in the link: the built-in gf, which also opens folders.
    local ok, err = pcall(vim.cmd, "normal! gf")
    if not ok then
      -- Show only Neovim's own message, such as "E447: Can't find file".
      vim.notify(err:match("E%d+:.*") or err, vim.log.levels.ERROR)
    end
    return
  end

  if path == "" then
    -- A heading of this file. Remember this place, so that Ctrl-o comes back.
    vim.cmd("normal! m'")
  else
    -- A link is relative to the file it is in, so look there first. Then
    -- look in the folder Neovim was started in, as gf does too. %:h is the
    -- folder of the current file; normalize() turns "a/../b" into "b".
    local next_to_file = vim.fs.normalize(vim.fs.joinpath(vim.fn.expand("%:h"), path))
    local file = vim.fn.filereadable(next_to_file) == 1 and next_to_file or path
    if vim.fn.filereadable(file) == 0 then
      vim.notify("Can't find file: " .. path, vim.log.levels.ERROR)
      return
    end
    vim.cmd.edit(vim.fn.fnameescape(file))
  end

  local row = find_heading(anchor)
  if not row then
    vim.notify("No heading for #" .. anchor, vim.log.levels.WARN)
    return
  end
  vim.api.nvim_win_set_cursor(0, { row, 0 })
  -- Show the heading mid-screen, like the other jumps.
  vim.cmd("normal! zz")
end

-- The FileType event runs when a markdown file opens. buffer = args.buf makes
-- gf work this way in that file only.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "gf", follow_link, {
      buffer = args.buf,
      desc = "Open the file of the link, at its heading",
    })
  end,
})
