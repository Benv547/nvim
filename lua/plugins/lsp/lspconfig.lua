return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- Va permettre de remplir le plugin de complétion automatique nvim-cmp
    -- avec les résultats des LSP
    "hrsh7th/cmp-nvim-lsp",
    -- Ajoute les « code actions » de type renommage de fichiers intelligent, etc
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/lazydev.nvim", ft = "lua", opts = {} },
  },
  config = function()
    -- ── Diagnostics ───────────────────────────────────────────────────────────
    -- Depuis Neovim 0.11, le texte virtuel est désactivé par défaut : on le réactive
    vim.diagnostic.config({
      virtual_text = true,
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.INFO] = "",
          [vim.diagnostic.severity.HINT] = "󰌵",
        },
      },
    })

    -- ── Capacités communes à tous les serveurs (complétion nvim-cmp) ─────────
    vim.lsp.config("*", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    -- ── Raccourcis et inlay hints, uniquement dans les buffers avec un LSP ───
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "gR", "<cmd>Telescope lsp_references<CR>", "Références (LSP)")
        map("n", "gD", vim.lsp.buf.declaration, "Aller à la déclaration")
        map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Aller à la définition")
        map("n", "gI", "<cmd>Telescope lsp_implementations<CR>", "Implémentations (LSP)")
        map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", "Définition du type")
        map("n", "gs", vim.lsp.buf.signature_help, "Signature")
        map("n", "K", vim.lsp.buf.hover, "Documentation sous le curseur")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Renommer le symbole")
        map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Diagnostics du buffer")
        map("n", "<leader>d", vim.diagnostic.open_float, "Diagnostic de la ligne")
        map("n", "[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, "Diagnostic précédent")
        map("n", "]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, "Diagnostic suivant")
        map("n", "<leader>rs", "<cmd>LspRestart<CR>", "Redémarrer le LSP")

        -- Python : ruff ne fournit pas de vraie documentation au survol,
        -- on laisse pylsp s'en charger pour éviter les doublons
        if client and client.name == "ruff" then
          client.server_capabilities.hoverProvider = false
        end

        -- Inlay hints activés par défaut, avec un raccourci pour les masquer
        if client and client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          map("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
          end, "Afficher/masquer les inlay hints")
        end
      end,
    })

    -- ── Rust ──────────────────────────────────────────────────────────────────
    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          check = {
            command = "clippy",
          },
          inlayHints = {
            renderColons = true,
            typeHints = {
              enable = true,
              hideClosureInitialization = false,
              hideNamedConstructor = false,
            },
          },
          diagnostics = {
            enable = true,
            styleLints = {
              enable = true,
            },
          },
        },
      },
    })

    -- ── Python ────────────────────────────────────────────────────────────────
    -- Répartition des rôles :
    --   pylsp → complétion, documentation, navigation, typage (mypy)
    --   ruff  → lint, tri des imports et formatage (via conform)
    -- Les plugins pylsp qui feraient doublon avec ruff sont désactivés.
    -- mypy et rope sont des extensions à installer une fois dans nvim :
    --   :PylspInstall pylsp-mypy pylsp-rope
    vim.lsp.config("pylsp", {
      settings = {
        pylsp = {
          plugins = {
            -- formatage et lint : délégués à ruff
            black = { enabled = false },
            autopep8 = { enabled = false },
            yapf = { enabled = false },
            pyflakes = { enabled = false },
            pycodestyle = { enabled = false },
            mccabe = { enabled = false },
            pylsp_isort = { enabled = false },
            -- vérification de types
            pylsp_mypy = { enabled = true },
            -- complétion
            jedi_completion = { fuzzy = true },
            rope_completion = { enabled = true },
            rope_autoimport = { enabled = true },
          },
        },
      },
    })

    vim.lsp.config("ruff", {
      init_options = {
        settings = {
          -- on ajoute les avertissements sur le tri des imports (règles « I »)
          lint = { extendSelect = { "I" } },
        },
      },
    })

    -- ── SQL ───────────────────────────────────────────────────────────────────
    -- sqlls fonctionne sans configuration pour la complétion de base ;
    -- pour la complétion des tables, ajouter un fichier .sqllsrc.json
    -- décrivant la connexion à la base à la racine du projet.

    -- ── TypeScript / JavaScript / React / Vue ────────────────────────────────
    local inlay_hints = {
      includeInlayParameterNameHints = "all",
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    }

    -- Plugin TypeScript fourni par vue-language-server (installé par Mason) :
    -- il permet à ts_ls de comprendre le <script lang="ts"> des fichiers .vue
    local vue_plugin_path = vim.fn.stdpath("data")
      .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

    -- Pas de root_dir figé : nvim-lspconfig détecte la racine de chaque projet
    vim.lsp.config("ts_ls", {
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "vue",
      },
      init_options = {
        plugins = {
          {
            name = "@vue/typescript-plugin",
            location = vue_plugin_path,
            languages = { "vue" },
          },
        },
      },
      settings = {
        typescript = { inlayHints = inlay_hints },
        javascript = { inlayHints = inlay_hints },
      },
    })

    -- ── Angular ───────────────────────────────────────────────────────────────
    -- La config par défaut de nvim-lspconfig gère déjà les templates (htmlangular)
    -- et trouve @angular/language-service dans le node_modules du projet.
    -- Rien à surcharger.

    -- ── HTML (y compris les templates Angular) ──────────────────────────────
    vim.lsp.config("html", {
      filetypes = { "html", "htmlangular" },
    })

    -- ── CSS / SCSS / Less ────────────────────────────────────────────────────
    vim.lsp.config("cssls", {
      settings = {
        css = { validate = true },
        scss = { validate = true },
        less = { validate = true },
      },
    })
  end,
}
