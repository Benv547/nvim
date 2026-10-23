return {
  "mason-org/mason.nvim",
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    -- installe aussi les outils qui ne sont pas des LSP (formateurs)
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    require("mason-lspconfig").setup({
      automatic_enable = true,
      -- Serveurs LSP installés automatiquement
      -- Liste complète : https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
      ensure_installed = {
        -- Rust
        "rust_analyzer",
        "taplo", -- Cargo.toml
        -- Web
        "html",
        "cssls",
        "emmet_language_server",
        "tailwindcss",
        "ts_ls",
        "eslint",
        "angularls",
        "vue_ls",
        -- Python
        "pylsp",
        "ruff",
        -- SQL
        "sqlls",
        -- Divers
        "jsonls",
        "yamlls",
        "lua_ls",
      },
    })

    -- Formateurs appelés par conform.nvim
    -- (rustfmt n'est pas listé : il est fourni par rustup)
    require("mason-tool-installer").setup({
      ensure_installed = {
        "prettier",
        "stylua",
      },
    })
  end,
}
