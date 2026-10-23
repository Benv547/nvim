# Configuration Neovim

Basée sur [vjousse/neovim-from-scratch](https://github.com/vjousse/neovim-from-scratch),
adaptée pour Rust, HTML/CSS/JS, TypeScript, React, Vue, Angular, Python et SQL.

## Prérequis

- Neovim 0.11 ou plus récent
- `git`, `make` et un compilateur C (`gcc` ou `clang`) : compilation de telescope-fzf-native,
  du `jsregexp` de LuaSnip et des parsers treesitter
- le CLI `tree-sitter` (exigé par la branche `main` de nvim-treesitter)
- `ripgrep` (recherche dans les fichiers avec Telescope)
- Node.js et npm (serveurs LSP web et prettier installés par Mason)
- `rustup` avec les composants `rustfmt` et `clippy`
- Python 3 (pylsp, installé par Mason) ; puis dans Neovim : `:PylspInstall pylsp-mypy pylsp-rope`
- une Nerd Font dans le terminal (icônes)

Après installation, lancer `:checkhealth` pour vérifier que tout est en place.

## Installation

    git clone git@github.com:Benv547/nvim.git ~/.config/nvim

Sous Windows, le dossier de configuration est `%LOCALAPPDATA%\nvim`.

## Raccourcis principaux

La touche leader est Espace. `<leader>?` affiche tous les raccourcis.

| Raccourci | Action |
| --- | --- |
| `<leader>e` | Explorateur de fichiers |
| `<leader>ff` / `fg` / `fb` / `fx` | Fichiers / texte / buffers / mot sous le curseur |
| `<S-h>` / `<S-l>` | Buffer précédent / suivant |
| `<leader>bd` | Fermer le buffer |
| `gd` / `gR` / `gI` / `gt` | Définition / références / implémentations / type |
| `K` | Documentation |
| `<leader>ca` / `<leader>rn` | Code action / renommer |
| `[d` / `]d` / `<leader>d` | Diagnostic précédent / suivant / détail |
| `<leader>xx` | Liste des diagnostics (Trouble) |
| `<leader>mp` | Formater |
| `<leader>th` | Afficher/masquer les inlay hints |
| `<leader>at` | Basculer entre .ts et .html (Angular) |
| `<A-j>` / `<A-k>` | Déplacer la ligne ou la sélection |
| `]h` / `[h` / `<leader>hs` | Hunk git suivant / précédent / indexer |
| `<C-l>` / `<C-h>` (insertion) | Champ suivant / précédent d'un snippet |
