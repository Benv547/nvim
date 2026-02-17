return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  build = ":TSUpdate",
  lazy = false,
  config = function()
    local treesitter = require("nvim-treesitter.config")


    -- ← Initialisation de nvim-ts-autotag
    require("nvim-ts-autotag").setup()

    treesitter.setup({
      highlight = {
        enable = true,
      },
      indent = { enable = true },
      ensure_installed = {
        "angular",
        "bash",
        "dockerfile",
        "gitignore",
        "html",
        "javascript",
        "json",
        "lua",
        "css",
        "scss",
        "markdown",
        "markdown_inline",
        "python",
        "rst",
        "rust",
        "typescript",
        "vim",
        "yaml",
      },
      auto_install = true,
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
