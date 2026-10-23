return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- Noms des groupes affichés dans le menu de which-key
    spec = {
      { "<leader>b", group = "Buffer" },
      { "<leader>c", group = "Code" },
      { "<leader>f", group = "Rechercher" },
      { "<leader>h", group = "Git (hunks)" },
      { "<leader>m", group = "Formatage" },
      { "<leader>r", group = "Renommer / Redémarrer" },
      { "<leader>t", group = "Basculer (toggle)" },
      { "<leader>x", group = "Trouble" },
      { "<leader>y", group = "Copier" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = true })
      end,
      desc = "Tous les raccourcis (which-key)",
    },
  },
}
