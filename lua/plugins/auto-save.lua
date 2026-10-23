return {
  "okuuva/auto-save.nvim",
  event = "VeryLazy",
  opts = {
    -- On sauvegarde seulement en quittant le buffer ou en perdant le focus,
    -- pour éviter que le formatage à la sauvegarde ne s'exécute en pleine édition
    trigger_events = {
      immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
      defer_save = {},
      cancel_deferred_save = {},
    },
  },
}
