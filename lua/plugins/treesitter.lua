-- nvim-treesitter, branche `main` (réécriture du plugin)
-- Prérequis : le CLI `tree-sitter` et un compilateur C dans le PATH
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- la branche main ne supporte pas le chargement différé
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- Fermeture/renommage automatique des balises HTML, JSX, Vue, Angular
    require("nvim-ts-autotag").setup()

    -- Installe les parsers manquants (ne fait rien s'ils sont déjà présents)
    require("nvim-treesitter").install({
      -- Rust
      "rust",
      "toml",
      -- Web
      "html",
      "angular",
      "css",
      "scss",
      "javascript",
      "jsdoc",
      "typescript",
      "tsx",
      "vue",
      "json",
      -- Python
      "python",
      "rst", -- docstrings
      -- SQL
      "sql",
      -- Divers
      "bash",
      "dockerfile",
      "gitignore",
      "lua",
      "markdown",
      "markdown_inline",
      "regex",
      "vim",
      "vimdoc",
      "yaml",
    })

    -- Active la coloration et l'indentation treesitter quand un parser existe
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user-treesitter", { clear = true }),
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
