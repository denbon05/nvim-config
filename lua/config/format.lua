-- Type :Format and press Enter to tidy the current file with the project's
-- own tools, so the style comes from the project's settings, not from
-- Neovim:
--   Python      ruff check --fix, then ruff format. Ruff reads
--               [tool.ruff] in pyproject.toml, or ruff.toml.
--   JS and TS   eslint --fix, then prettier --write. Prettier goes last, so
--               it has the last word on the style. Both must be installed
--               in the project (node_modules), as Neovim uses no copy of its
--               own.
-- Only the current file changes. u undoes the whole format in one step.

-- The file types each tool takes. Prettier also tidies JSON, CSS, HTML,
-- YAML and markdown, so those get Prettier alone.
local js_types = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}
local prettier_types = {
  json = true,
  jsonc = true,
  css = true,
  scss = true,
  html = true,
  yaml = true,
  markdown = true,
}

-- Look for a program inside the project: in the folder of the file, then in
-- each folder above it, at the place given, such as node_modules/.bin/prettier.
-- Returns the program's full path and the folder it was found from, or nil.
local function find_upward(file, place)
  for dir in vim.fs.parents(file) do
    local path = vim.fs.joinpath(dir, place)
    if vim.fn.executable(path) == 1 then
      return path, dir
    end
  end
end

-- Run one tool and wait for it. cwd is the folder it runs in: the project
-- folder, where it looks for its settings. ok_codes lists the exit codes
-- that are not a failure. Returns true when it worked; otherwise shows the
-- tool's own message at the bottom.
local function run(name, cmd, cwd, ok_codes)
  -- vim.system starts the program directly, without a shell, so a path
  -- with spaces is safe.
  local result = vim.system(cmd, { cwd = cwd, text = true }):wait()
  if vim.tbl_contains(ok_codes, result.code) then
    return true
  end
  local message = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
  vim.notify(name .. " failed:\n" .. message, vim.log.levels.ERROR)
  return false
end

vim.api.nvim_create_user_command("Format", function()
  -- The full path of the file in this window. filereadable is 0 for a
  -- window with no file on disk, such as a new unsaved one.
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or vim.fn.filereadable(file) == 0 then
    print("This window shows no file on disk")
    return
  end

  -- The tools change the file on disk, so save my changes first.
  -- silent hides the "written" message.
  vim.cmd("silent write")

  local filetype = vim.bo.filetype
  local used = {}

  if filetype == "python" then
    -- The project's own Ruff in .venv, the version the project checks with.
    -- Otherwise the one from Homebrew.
    local ruff, root = find_upward(file, ".venv/bin/ruff")
    ruff = ruff or "ruff"
    root = root or vim.fs.dirname(file)

    -- --exit-zero: problems that can't be fixed by themselves are no
    -- failure, the error messages in the file show them anyway. --silent
    -- keeps Ruff from listing them here as well.
    if not run("ruff check", { ruff, "check", "--fix", "--exit-zero", "--silent", file }, root, { 0 }) then
      return
    end
    if not run("ruff format", { ruff, "format", "--silent", file }, root, { 0 }) then
      return
    end
    used = { "ruff" }
  elseif js_types[filetype] or prettier_types[filetype] then
    local eslint, eslint_root = find_upward(file, "node_modules/.bin/eslint")
    local prettier, prettier_root = find_upward(file, "node_modules/.bin/prettier")

    -- ESLint for code only. Exit code 1 means problems are left that it
    -- can't fix by itself: no failure, the error messages show them. Even
    -- if ESLint fails, for example with no settings file, Prettier still
    -- runs.
    if eslint and js_types[filetype] then
      run("eslint", { eslint, "--fix", file }, eslint_root, { 0, 1 })
      table.insert(used, "eslint")
    end
    if prettier then
      if not run("prettier", { prettier, "--write", file }, prettier_root, { 0 }) then
        return
      end
      table.insert(used, "prettier")
    end
    if #used == 0 then
      print("No eslint or prettier in this project's node_modules: nothing changed")
      return
    end
  else
    print("No formatter for file type: " .. (filetype ~= "" and filetype or "none"))
    return
  end

  -- Read the file again from disk, keeping the cursor and the scroll where
  -- they were. Neovim keeps the undo history over the reload, so u undoes
  -- the format.
  local view = vim.fn.winsaveview()
  vim.cmd("silent edit")
  vim.fn.winrestview(view)
  print("Formatted with " .. table.concat(used, " and "))
end, { desc = "Tidy the current file with the project's tools" })
