return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({})

    -- Wrapper autour du toggle nvim-tree :
    -- on réapplique le layout de la sidebar juste après, de façon synchrone
    vim.keymap.set("n", "<leader>e", function()
      -- 1. Ouvre/ferme nvim-tree normalement
      vim.cmd("NvimTreeFindFileToggle")

      -- 2. Réapplique immédiatement le layout de la sidebar
      --    (synchrone : nvim-tree a déjà fini à ce stade)
      local ok, sidebar = pcall(require, "sidebar-notepad")
      if ok then
        sidebar.reapply_layout()
      end
    end, { desc = "Ouverture/fermeture de l'explorateur de fichiers" })
  end,
}