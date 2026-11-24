
-- Plugins. vim.pack is the plugin manager built into Neovim 0.12.
-- On the first start it asks before downloading anything: press y.
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

-- Load fzf-lua and start it with its default settings, except for the keys
-- below.
local fzf = require("fzf-lua")
fzf.setup({
  -- Options for fzf itself, in every list.
  fzf_opts = {
    -- Moving past the end of a list continues at the other end: Up on the
    -- first line jumps to the last one, Down on the last line to the first.
    ["--cycle"] = true,
  },
  keymap = {
    fzf = {
      -- true keeps every default key of fzf-lua that is not listed here.
      true,
      -- Shift-Down and Shift-Up scroll the preview by half a page, like
      -- Ctrl-d and Ctrl-u in a file. The default is a whole page, after
      -- which it is easy to lose your place. The preview is drawn by fzf,
      -- not by Neovim, so it can't be animated the way neoscroll does it.
      ["shift-down"] = "preview-half-page-down",
      ["shift-up"] = "preview-half-page-up",
    },
  },
  -- Options for the file search only (Space f and Space Shift-f).
  files = {
    -- The same layout as the list of changed files on Space g.
    winopts = {
      -- Use the whole screen.
      fullscreen = true,
      preview = {
        -- Put the preview on the right and give it 70% of the width,
        -- which leaves a narrow column for the file list.
        layout = "horizontal",
        horizontal = "right:70%",
      },
    },
  },
  -- Options for the text search (Space / and :FzfLua grep).
  grep = {
    winopts = {
      -- Use the whole screen.
      fullscreen = true,
      preview = {
        -- Put the file on the right and give it 60% of the width. A found
        -- line shows the path and the text, so the list needs more room
        -- than the file list does.
        layout = "horizontal",
        horizontal = "right:60%",
        -- Continue a long line on the next row. Without this it is cut off.
        wrap = true,
      },
    },
  },
  -- Options for :FzfLua git_blame, the list of who changed each line.
  git = {
    blame = {
      winopts = {
        -- Use the whole screen.
        fullscreen = true,
        preview = {
          -- Put the commit below the list and give it 70% of the height.
          -- Both get the full width: a blame line starts with the commit,
          -- the author and the date, so a narrow column would leave no room
          -- for the code.
          layout = "vertical",
          vertical = "down:70%",
          -- Continue a long line on the next row. Without this it is cut off.
          wrap = true,
        },
      },
    },
  },
})

-- Tap Space, then f, to find a file by typing part of its name (like Cmd+P).
vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Find files" })

-- Tap Space, then Shift-f, for the same search including the files git
-- ignores, such as .env. The big generated folders stay left out.
vim.keymap.set("n", "<leader>F", function()
  fzf.files({
    -- Tell fd not to read .gitignore.
    no_ignore = true,
    -- The default fd options, plus the folders to skip.
    fd_opts = "--color=never --type f --type l --exclude .git --exclude .venv"
      .. " --exclude node_modules --exclude __pycache__ --exclude '.*_cache'",
  })
end, { desc = "Find files, ignored too" })

-- Tap Space, then /, to search for text in every file of the project.
--
-- Keep mode: Ctrl-s inside the search turns it on or off. While it is on,
-- every Space / opens with the text I searched for last time and the same
-- results, and the prompt says "Grep (kept)>". While it is off, Space /
-- starts empty. Neovim forgets the mode when it closes.
local keep_search = false

-- Review mode: Ctrl-r inside the search turns it on or off. While it is on,
-- the search looks only in the files that still have unstaged changes and in
-- new files git doesn't track yet, the same files as the "to review" view of
-- Space g, and the prompt says "to review". It stays on for every Space /
-- until I turn it off. Neovim forgets the mode when it closes.
local review_only = false

-- The files to review, as paths from the folder Neovim was started in.
-- `git diff --name-only --relative` lists the files with unstaged changes,
-- `git ls-files --others --exclude-standard` the new files that .gitignore
-- doesn't hide. A deleted file is no longer on disk, so it is left out.
local function files_to_review()
  local paths = vim.fn.systemlist(
    "git diff --name-only --relative; git ls-files --others --exclude-standard"
  )
  return vim.tbl_filter(function(path)
    return vim.fn.filereadable(path) == 1
  end, paths)
end

-- The prompt names the modes that are on, such as "Grep (kept, to review)> ".
local function search_prompt()
  local modes = {}
  if keep_search then
    table.insert(modes, "kept")
  end
  if review_only then
    table.insert(modes, "to review")
  end
  if #modes == 0 then
    return "Grep> "
  end
  return "Grep (" .. table.concat(modes, ", ") .. ")> "
end

-- Open the text search. resume = true brings back the last text.
local function search_text(resume)
  -- nil searches the whole project.
  local search_paths = nil
  if review_only then
    search_paths = files_to_review()
    if #search_paths == 0 then
      -- Nothing to review: search everything, rather than find nothing.
      review_only = false
      search_paths = nil
      print("No files to review: searching every file")
    end
  end

  fzf.live_grep({
    resume = resume,
    prompt = search_prompt(),
    search_paths = search_paths,
    actions = {
      ["ctrl-s"] = {
        -- Switch the mode, then open the search again right away with the
        -- text I have typed, so only the prompt changes.
        fn = function()
          keep_search = not keep_search
          search_text(true)
        end,
        desc = "keep-search",
      },
      ["ctrl-r"] = {
        -- The same for review mode: the text stays, the files change.
        fn = function()
          review_only = not review_only
          search_text(true)
        end,
        desc = "to-review",
      },
    },
  })
end

vim.keymap.set("n", "<leader>/", function()
  search_text(keep_search)
end, { desc = "Search text" })

-- Tap Space, then b, to pick one of the open files (buffers) from a list.
vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Open buffers" })

-- Tap Space, then Shift-b, to see who changed each line of the file and when
-- ("blame"). The commit of the selected line is shown below the list, and
-- Enter jumps to that line in the file.
vim.keymap.set("n", "<leader>B", fzf.git_blame, { desc = "Git blame" })

-- The git command that lists the changed files, one per line. Each line
-- starts with two letters: the first is the staged state of the file and the
-- second is its unstaged state. A space means "no change of that kind".
local git_status_cmd = "git -c color.status=false --no-optional-locks status --porcelain=v1 -u"

-- The three views of the list of changed files. For each view:
--   prompt   the text in front of the search field, to tell the views apart
--   filter   added to git_status_cmd to keep only some of its lines
--   diff     the git command whose output is shown on the right
local git_views = {
  -- Every changed file, with all its changes since the last commit.
  all = { prompt = "All changes> ", filter = "", diff = "git diff --color HEAD" },
  -- Only the files with unstaged changes, and only those changes. grep -v
  -- drops the lines of fully staged files: a letter, then a space.
  unstaged = {
    prompt = "To review> ",
    filter = " | grep -v '^[MADRC] '",
    diff = "git diff --color",
  },
  -- Only the files with staged changes, and only those changes. grep keeps
  -- the lines whose first letter says "staged".
  staged = {
    prompt = "Staged> ",
    filter = " | grep '^[MADRC]'",
    diff = "git diff --color --cached",
  },
}

-- Open the list of changed files in one of the three views.
local function show_git_changes(view_name)
  local view = git_views[view_name]

  -- Remember the view, so that the next Space g opens it again. Neovim saves
  -- a global variable whose name is all capitals when it quits (in the
  -- "shada" file), so the view is remembered after a restart too.
  vim.g.GIT_CHANGES_VIEW = view_name

  -- The settings fzf-lua uses to show a diff on the right. They are copied,
  -- and the copy gets this view's diff command.
  local previewer = vim.deepcopy(require("fzf-lua.config").globals.previewers.git_diff)
  previewer.cmd_modified = view.diff
  -- A deleted file is no longer on disk, so git needs "--" in front of its
  -- name to know that it is a file name.
  previewer.cmd_deleted = view.diff .. " --"

  fzf.git_status({
    prompt = view.prompt,
    cmd = git_status_cmd .. view.filter,
    previewer = previewer,
    winopts = {
      -- Use the whole screen.
      fullscreen = true,
      preview = {
        -- Put the diff on the right and give it 70% of the width,
        -- which leaves a narrow column for the file list.
        layout = "horizontal",
        horizontal = "right:70%",
        -- Continue a long line on the next row. Without this it is cut off.
        wrap = true,
      },
    },
    actions = {
      -- Inside the list, hold Ctrl and press r, s or a to switch the view:
      -- to review (unstaged), staged, all.
      ["ctrl-r"] = function()
        show_git_changes("unstaged")
      end,
      ["ctrl-s"] = function()
        show_git_changes("staged")
      end,
      ["ctrl-a"] = function()
        show_git_changes("all")
      end,
    },
  })
end

-- Tap Space, then g, to list the files changed since the last commit ("git").
-- The list is on the left and the diff of the selected file is on the right.
-- Shift-Down and Shift-Up scroll the diff, and Enter opens the file.
-- It opens the view used last; the very first time, all the changes.
vim.keymap.set("n", "<leader>g", function()
  local view_name = vim.g.GIT_CHANGES_VIEW
  if not git_views[view_name] then
    view_name = "all"
  end
  show_git_changes(view_name)
end, { desc = "Git changes" })

-- Smooth scrolling. Without it a scroll redraws the screen in one step and
-- it is easy to lose your place. neoscroll moves the text gradually instead.
vim.pack.add({ "https://github.com/karb94/neoscroll.nvim" })

-- Load neoscroll with its default settings. It animates Ctrl-d, Ctrl-u,
-- Ctrl-f, Ctrl-b, Ctrl-e, Ctrl-y, zt, zz and zb.
require("neoscroll").setup({})

-- Tap Space, then j or k, to scroll half a screen down or up, like Ctrl-d and
-- Ctrl-u, which keep working: the thumb and a home row finger, no Ctrl. j is
-- down and k is up, as for the cursor. neoscroll animates them the same way.
local neoscroll = require("neoscroll")
vim.keymap.set({ "n", "x" }, "<leader>j", function()
  neoscroll.ctrl_d({ duration = 250 })
end, { desc = "Scroll half a screen down" })
vim.keymap.set({ "n", "x" }, "<leader>k", function()
  neoscroll.ctrl_u({ duration = 250 })
end, { desc = "Scroll half a screen up" })
