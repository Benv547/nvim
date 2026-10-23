return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-buffer",  -- source pour compléter le texte déjà présent dans le buffer
    "hrsh7th/cmp-path",    -- source pour compléter les chemins des fichiers
    "hrsh7th/cmp-cmdline", -- source pour les completions de la cmdline de vim
    {
      "L3MON4D3/LuaSnip",
      -- follow latest release.
      version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      -- install jsregexp (optional!).
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip",               -- ajoute LuaSnip à l'autocompletion
    "rafamadriz/friendly-snippets",           -- collection de snippets pratiques
    "hrsh7th/cmp-emoji",                      -- complétion d'émojis à la saisie de :
    "onsails/lspkind.nvim",                   -- vs-code pictogrammes
    "roobert/tailwindcss-colorizer-cmp.nvim", -- colorise les classes tailwind dans les suggestions de nvim-cmp
  },
  config = function()
    local cmp = require("cmp")

    local luasnip = require("luasnip")

    local lspkind = require("lspkind")

    -- chargement des snippets (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = { -- on utilise luasnip comme moteur de snippets
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = {
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        -- Entrée ne valide que si un élément a été choisi explicitement :
        -- sinon on passe à la ligne normalement, même si le menu est ouvert
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        -- Ctrl-l / Ctrl-h : champ suivant / précédent dans un snippet
        -- (Tab reste réservé à Copilot ; hors snippet, Ctrl-h garde son rôle d'effacement)
        ["<C-l>"] = cmp.mapping(function(fallback)
          if luasnip.locally_jumpable(1) then
            luasnip.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-h>"] = cmp.mapping(function(fallback)
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      },

      -- sources pour l'autocompletion
      sources = cmp.config.sources({
        { name = "lazydev", group_index = 0 }, -- API Neovim dans les fichiers de config lua
        { name = "nvim_lsp" }, -- lsp
        { name = "luasnip" },  -- snippets
        { name = "buffer" },   -- texte du buffer courant
        { name = "path" },     -- chemins du système de fichier
        { name = "emoji" },    -- emojis
      }),

      formatting = {
        -- Comportement par défaut
        expandable_indicator = true,
        -- Champs affichés par défaut
        fields = { 'abbr', 'icon', 'kind', 'menu' },
        format = lspkind.cmp_format({
          before = require("tailwindcss-colorizer-cmp").formatter, -- colorise les classes tailwind dans les suggestions de nvim-cmp
          mode = "symbol_text",
          -- On suffixe chaque entrée par son type
          ellipsis_char = '...',
          symbol_map = {
            Text = "󰉿",
            Method = "󰆧",
            Function = "󰊕",
            Constructor = "",
            Field = "󰜢",
            Variable = "󰀫",
            Class = "󰠱",
            Interface = "",
            Module = "",
            Property = "󰜢",
            Unit = "󰑭",
            Value = "󰎠",
            Enum = "",
            Keyword = "󰌋",
            Snippet = "",
            Color = "󰏘",
            File = "󰈙",
            Reference = "󰈇",
            Folder = "󰉋",
            EnumMember = "",
            Constant = "󰏿",
            Struct = "󰙅",
            Event = "",
            Operator = "󰆕",
            TypeParameter = "",
          },
        }),
      },
    })

    -- `/` complétion
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- `:` complétion
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        {
          name = "cmdline",
          option = {
            ignore_cmds = { "Man", "!" },
          },
        },
      }),
    })
  end,
}
