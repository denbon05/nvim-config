
-- Language servers. A language server is a separate program that understands
-- your code. Neovim asks it where things are defined, what is wrong, and what
-- to suggest while you type. LSP is the name of the protocol they talk in.

-- nvim-lspconfig holds ready-made settings for each server, so we don't write them.
vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

-- Completion menu: show it even with one match, don't pick an item until I do,
-- and show extra details in a small popup next to it.
vim.o.completeopt = "menuone,noselect,popup"

-- Start these servers for matching files: basedpyright and Ruff for Python,
-- tsc for TypeScript and JavaScript. Each server must be installed with
-- Homebrew. basedpyright is Pyright with more checks; it reads the
-- [tool.basedpyright] settings of a project's pyproject.toml, so the editor
-- shows the same problems as the project's own type check. Started with
-- `uv run nvim .`, Neovim uses the project's own basedpyright from .venv.
-- tsc is the language server built into TypeScript 7. The older ts_ls server
-- needs TypeScript 6 or older and fails with "Could not find a valid
-- TypeScript installation" next to version 7.
vim.lsp.enable({ "basedpyright", "ruff", "tsc" })

-- Show error messages at the end of the line where they happen.
vim.diagnostic.config({ virtual_text = true })

-- When a server starts working on a file, set up the extras below for that file.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- gd means "go to definition": jump to where the name under the cursor is
    -- defined, and scroll so that line is in the middle of the window.
    vim.keymap.set("n", "gd", function()
      -- on_list receives the places the servers found, instead of jumping itself.
      vim.lsp.buf.definition({
        on_list = function(found)
          local place = found.items[1]

          -- Remember where I am, so Ctrl-o comes back here.
          vim.cmd("normal! m'")

          -- Show the file that holds the definition in this window.
          local buf = vim.fn.bufadd(place.filename)
          vim.bo[buf].buflisted = true
          vim.api.nvim_win_set_buf(0, buf)

          -- Put the cursor on the name. Columns count from 0 here, hence "- 1".
          vim.api.nvim_win_set_cursor(0, { place.lnum, place.col - 1 })

          -- zz scrolls the cursor line to the middle of the window.
          vim.cmd("normal! zz")
        end,
      })
    end, { buffer = ev.buf, desc = "Go to definition" })

    -- If this server can suggest completions, open the menu by itself while typing.
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
