-- plugin/sidebar-notepad.lua
-- Point d'entrée chargé automatiquement par Neovim

if vim.g.loaded_sidebar_notepad then
  return
end
vim.g.loaded_sidebar_notepad = true

-- Chargement différé : setup appelé par l'utilisateur via require().setup()
-- Ce fichier évite juste le double-chargement.
