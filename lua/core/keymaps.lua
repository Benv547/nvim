-- On définit notre touche leader sur espace
vim.g.mapleader = " "

-- Raccourci pour la fonction set
local keymap = vim.keymap.set

-- on copie le fichier dans le presse-papiers du système
keymap('n', '<leader>ya', ':%y+<CR>', { noremap = true, silent = true })
-- on utilise ;; pour sortir du monde insertion
keymap("i", ";;", "<ESC>", { desc = "Sortir du mode insertion avec ;;" })

-- on efface le surlignage de la recherche
keymap("n", "<leader>nh", ":nohl<CR>", { desc = "Effacer le surlignage de la recherche" })

-- I déplace le texte sélectionné vers le haut en mode visuel (activé avec v)
keymap("v", "<S-i>", ":m .-2<CR>==", { desc = "Déplace le texte sélectionné vers le haut en mode visuel" })
-- K déplace le texte sélectionné vers le bas en mode visuel (activé avec v)
keymap("v", "<S-k>", ":m .+1<CR>==", { desc = "Déplace le texte sélectionné vers le bas en mode visuel" })

-- I déplace le texte sélectionné vers le haut en mode visuel bloc (activé avec V)
keymap(
  "x",
  "<S-i>",
  ":move '<-2<CR>gv-gv",
  { desc = "Déplace le texte sélectionné vers le haut en mode visuel bloc" }
)
-- K déplace le texte sélectionné vers le bas en mode visuel (activé avec V)
keymap(
  "x",
  "<S-k>",
  ":move '>+1<CR>gv-gv",
  { desc = "Déplace le texte sélectionné vers le bas en mode visuel bloc" }
)

-- Changement de fenêtre avec Ctrl + déplacement uniquement au lieu de Ctrl-w + déplacement
keymap("n", "<C-h>", "<C-w>h", { desc = "Déplace le curseur dans la fenêtre de gauche" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Déplace le curseur dans la fenêtre du bas" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Déplace le curseur dans la fenêtre du haut" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Déplace le curseur dans la fenêtre droite" })

-- Ajoutez dans votre init.lua
keymap('n', '<Up>', '<Nop>', { desc = 'Disable up arrow' })
keymap('n', '<Down>', '<Nop>', { desc = 'Disable down arrow' })
keymap('n', '<Left>', '<Nop>', { desc = 'Disable left arrow' })
keymap('n', '<Right>', '<Nop>', { desc = 'Disable right arrow' })

-- Navigation entre les buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Dans votre configuration
keymap('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
keymap('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })
keymap('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
keymap('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
keymap('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })

-- Navigation entre .ts et .html
keymap('n', '<leader>at', function()
  local file = vim.fn.expand('%:r')
  if vim.fn.expand('%:e') == 'ts' then
    vim.cmd('edit ' .. file .. '.html')
  else
    vim.cmd('edit ' .. file .. '.ts')
  end
end, { desc = 'Toggle between TS and HTML' })
