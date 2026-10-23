-- On définit les touches leader sur espace (avant le chargement de lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Raccourci pour la fonction set
local keymap = vim.keymap.set

-- on copie le fichier entier dans le presse-papiers du système
keymap("n", "<leader>ya", ":%y+<CR>", { silent = true, desc = "Copier tout le fichier" })

-- on utilise ;; pour sortir du mode insertion
keymap("i", ";;", "<ESC>", { desc = "Sortir du mode insertion avec ;;" })

-- on efface le surlignage de la recherche
keymap("n", "<leader>nh", ":nohl<CR>", { silent = true, desc = "Effacer le surlignage de la recherche" })

-- Alt-j / Alt-k déplacent la ligne ou la sélection
-- (I et K restent libres : Ctrl-v + I permet toujours l'insertion multi-lignes)
keymap("n", "<A-j>", ":move .+1<CR>==", { silent = true, desc = "Descendre la ligne" })
keymap("n", "<A-k>", ":move .-2<CR>==", { silent = true, desc = "Monter la ligne" })
keymap("x", "<A-j>", ":move '>+1<CR>gv=gv", { silent = true, desc = "Descendre la sélection" })
keymap("x", "<A-k>", ":move '<-2<CR>gv=gv", { silent = true, desc = "Monter la sélection" })

-- Changement de fenêtre avec Ctrl + déplacement au lieu de Ctrl-w + déplacement
keymap("n", "<C-h>", "<C-w>h", { desc = "Fenêtre de gauche" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Fenêtre du bas" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Fenêtre du haut" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Fenêtre de droite" })

-- Désactivation des flèches en mode normal
keymap("n", "<Up>", "<Nop>", { desc = "Flèche haut désactivée" })
keymap("n", "<Down>", "<Nop>", { desc = "Flèche bas désactivée" })
keymap("n", "<Left>", "<Nop>", { desc = "Flèche gauche désactivée" })
keymap("n", "<Right>", "<Nop>", { desc = "Flèche droite désactivée" })

-- Navigation entre les buffers : voir lua/plugins/bufferline.lua (<S-h> / <S-l>)
-- Raccourcis LSP : voir lua/plugins/lsp/lspconfig.lua (actifs seulement quand un LSP est attaché)

-- Angular : bascule entre .ts et .html d'un même composant
keymap("n", "<leader>at", function()
  local file = vim.fn.expand("%:r")
  if vim.fn.expand("%:e") == "ts" then
    vim.cmd("edit " .. file .. ".html")
  else
    vim.cmd("edit " .. file .. ".ts")
  end
end, { desc = "Basculer entre TS et HTML" })
