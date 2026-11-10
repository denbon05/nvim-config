
-- Language servers. A language server is a separate program that understands
-- your code. Neovim asks it where things are defined, what is wrong, and what
-- to suggest while you type. LSP is the name of the protocol they talk in.

-- nvim-lspconfig holds ready-made settings for each server, so we don't write them.
vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

-- Completion menu: show it even with one match, don't pick an item until I do,
-- and show extra details in a small popup next to it.
vim.o.completeopt = "menuone,noselect,popup"

-- Start these servers for matching files: Pyright and Ruff for Python,
-- ts_ls for TypeScript. Each server must be installed with Homebrew.
vim.lsp.enable({ "pyright", "ruff", "ts_ls" })

-- Show error messages at the end of the line where they happen.
vim.diagnostic.config({ virtual_text = true })

-- When a server starts working on a file, set up the extras below for that file.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- gd means "go to definition": jump to where the name under the cursor is defined.
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })

    -- If this server can suggest completions, open the menu by itself while typing.
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
