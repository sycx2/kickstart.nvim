-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- load the plugin before saving
    keys = {
      {
        "<leader>f",
        function() require("conform").format({ lsp_fallback = true }) end,
        desc = "Format",
      },
    },
    opts = {
      formatters_by_ft = {
        -- first use isort and then black
        python = { "isort", "black" },
        -- "inject" is a special formatter from conform.nvim, which
        -- formats treesitter-injected code. Basically, this makes
        -- conform.nvim format python codeblocks inside a markdown file.
        markdown = { "inject" },
        json = { "biome" },
      },
      -- enable format-on-save
      format_on_save = {
        -- when no formatter is setup for a filetype, fallback to formatting
        -- via the LSP. This is relevant e.g. for taplo (toml LSP), where the
        -- LSP can handle the formatting for us
        lsp_fallback = true,
      },
    },
  },
  -- external tools
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      { "williamboman/mason.nvim",           opts = true },
      { "williamboman/mason-lspconfig.nvim", opts = true },
    },
    opts = {
      ensure_installed = {
        "pyright",  -- LSP for python
        "ruff-lsp", -- linter for python (includes flake8, pep8, etc.)
        "debugpy",  -- debugger
        "black",    -- formatter
        "isort",    -- organize imports
        "taplo",    -- LSP for toml (for pyproject.toml files)
      },
    },
  },
}

