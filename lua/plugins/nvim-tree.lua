return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")

        -- Mappings par défaut
        api.config.mappings.default_on_attach(bufnr)

        -- Mapping $ pour exécuter une commande dans le chemin courant
        vim.keymap.set("n", "$", function()
          local node = api.tree.get_node_under_cursor()
          local path

          -- Si c'est un fichier, prendre le dossier parent
          if node.type == "file" then
            path = vim.fn.fnamemodify(node.absolute_path, ":h")
          else
            path = node.absolute_path
          end

          -- Ouvrir le command-line avec la commande préparée
          vim.fn.feedkeys(":! cd " .. vim.fn.shellescape(path) .. " && ", "n")
        end, { buffer = bufnr, desc = "nvim-tree: Run command in current path" })
      end,
    })
    -- On utilise <leader>e pour ouvrir/fermer l'explorateur
    vim.keymap.set(
      "n",
      "<leader>e",
      "<cmd>NvimTreeFindFileToggle<CR>",
      { desc = "Ouverture/fermeture de l'explorateur de fichiers" }
    )
  end,
}
