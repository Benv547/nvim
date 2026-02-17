# sidebar-notepad.nvim

Plugin Neovim affichant une **sidebar à droite** composée de :
- 🎥 **Zone caméra** (1/3 supérieur) — fond noir, prête pour un overlay postprod
- 📝 **Bloc-note** (2/3 inférieurs) — buffer Markdown persistant durant la session

---

## Structure du dossier

```
sidebar-notepad.nvim/
├── lua/
│   └── sidebar-notepad/
│       └── init.lua      ← logique principale
└── plugin/
    └── sidebar-notepad.lua  ← point d'entrée (anti double-chargement)
```

---

## Installation

### lazy.nvim (recommandé)

```lua
{
  dir = "~/.config/nvim/plugins/sidebar-notepad.nvim",  -- chemin local
  -- ou depuis GitHub :
  -- "ton-user/sidebar-notepad.nvim",
  config = function()
    require("sidebar-notepad").setup({
      -- options optionnelles (valeurs par défaut montrées)
      width   = 45,           -- largeur de la sidebar en colonnes
      keymap  = "<leader>sb", -- raccourci toggle
      note_filetype = "markdown",
    })
  end,
}
```

### packer.nvim

```lua
use {
  "ton-user/sidebar-notepad.nvim",
  config = function()
    require("sidebar-notepad").setup()
  end
}
```

### Installation manuelle

Copie le dossier dans `~/.local/share/nvim/site/pack/plugins/start/sidebar-notepad.nvim/`

---

## Utilisation

| Action | Raccourci / Commande |
|---|---|
| Ouvrir / Fermer la sidebar | `<leader>sb` (configurable) |
| Fermer depuis le bloc-note | `q` |
| Toggle via commande | `:SidebarToggle` |
| Focus sur le bloc-note | `:SidebarFocus` |

---

## Configuration complète

```lua
require("sidebar-notepad").setup({
  -- Largeur de la sidebar (en colonnes)
  width = 45,

  -- Raccourci clavier pour ouvrir/fermer
  keymap = "<leader>sb",

  -- Type de fichier du bloc-note (active la coloration syntaxique)
  note_filetype = "markdown",  -- ou "text", "org", etc.

  -- Texte affiché dans la zone caméra
  cam_placeholder = {
    "",
    "  ╔══════════════════════════╗",
    "  ║                          ║",
    "  ║     [ CAMERA FEED ]      ║",
    "  ║                          ║",
    "  ║   (postprod overlay)     ║",
    "  ║                          ║",
    "  ╚══════════════════════════╝",
    "",
  },
})
```

---

## Intégration caméra (postprod)

La zone noire du haut est un buffer Neovim vide avec fond `#0a0a0a`.  
Pour y superposer une vraie caméra, tu peux utiliser un outil externe
qui capture la fenêtre Neovim et y incruste un flux vidéo (OBS, ffmpeg overlay, etc.)
en ciblant les coordonnées de cette zone.

Obtenir la position de la fenêtre caméra en Lua :

```lua
local state = require("sidebar-notepad")
-- Depuis une autre config, tu peux interroger l'état via :SidebarFocus
-- ou exposer state.cam_win si besoin
```

---

## Highlights personnalisables

```lua
-- Dans ton init.lua / colorscheme, après le setup :
vim.api.nvim_set_hl(0, "SidebarCam",        { bg = "#000000", fg = "#333333" })
vim.api.nvim_set_hl(0, "SidebarNote",       { bg = "#1e2030", fg = "#cdd6f4" })
vim.api.nvim_set_hl(0, "SidebarNoteCursor", { bg = "#313244" })
```
