return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        -- Rust
        rust = { "rustfmt" },
        -- Web
        html = { "prettier" },
        htmlangular = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        -- Python (ruff_fix applique les corrections automatiques, puis imports et formatage)
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
        -- SQL : pas de formateur, pour ne pas réécrire tes requêtes à chaque sauvegarde
        -- Divers
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        lua = { "stylua" },
        -- toml : pas de formateur dédié, conform utilise le LSP taplo en repli
      },
      format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 1000,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Formater le fichier ou la sélection" })
  end,
}
