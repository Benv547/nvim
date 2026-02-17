return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({})

    -- Wrapper toggle : réapplique le layout de la sidebar après ouverture/fermeture
    vim.keymap.set("n", "<leader>e", function()
      vim.cmd("NvimTreeFindFileToggle")
      local ok, sidebar = pcall(require, "sidebar-notepad")
      if ok then sidebar.reapply_layout() end
    end, { desc = "Ouverture/fermeture de l'explorateur de fichiers" })
  end,
}