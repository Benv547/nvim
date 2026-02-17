return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  config = function()

    -- ── Helpers ───────────────────────────────────────────────────────────────

    local function is_real_buf(b)
      return vim.api.nvim_buf_is_valid(b)
        and vim.bo[b].buflisted
        and vim.bo[b].buftype == ""
        and vim.bo[b].filetype ~= "NvimTree"
        and vim.api.nvim_buf_get_name(b) ~= ""
    end

    local function is_protected_win(win)
      if not vim.api.nvim_win_is_valid(win) then return true end
      local b    = vim.api.nvim_win_get_buf(win)
      local name = vim.api.nvim_buf_get_name(b)
      local ft   = vim.bo[b].filetype
      return ft == "NvimTree"
          or name:find("Lexique547>Camera")  ~= nil
          or name:find("Lexique547>Notepad") ~= nil
    end

    local function best_replacement(exclude)
      local alt = vim.fn.bufnr("#")
      if alt ~= -1 and alt ~= exclude and is_real_buf(alt) then return alt end

      local bufs = vim.fn.getbufinfo({ buflisted = 1 })
      local real = vim.tbl_filter(function(i)
        return i.bufnr ~= exclude and is_real_buf(i.bufnr)
      end, bufs)

      if #real > 0 then
        table.sort(real, function(a, b) return a.lastused > b.lastused end)
        return real[1].bufnr
      end
      return nil
    end

    -- Redirige les fenêtres puis supprime le buffer
    local function close_buf(closing)
      if not is_real_buf(closing) then
        pcall(vim.cmd, "bd " .. closing)
        return
      end

      local repl = best_replacement(closing)

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if not is_protected_win(win)
          and vim.api.nvim_win_get_buf(win) == closing then
          if repl then
            vim.api.nvim_win_set_buf(win, repl)
          else
            vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
          end
        end
      end

      if vim.api.nvim_buf_is_valid(closing) then
        pcall(vim.cmd, "bd " .. closing)
      end
    end

    -- ── Configuration bufferline ──────────────────────────────────────────────

    require("bufferline").setup({
      options = {
        separator_style = "slant",
        offsets = { { filetype = "NvimTree", text = "", padding = 1 } },
        close_command        = function(bufnr) close_buf(bufnr) end,
        right_mouse_command  = function(bufnr) close_buf(bufnr) end,
        middle_mouse_command = function(bufnr) close_buf(bufnr) end,
      },
    })

    -- ── Commandes exposées ────────────────────────────────────────────────────

    -- :Bd  → même comportement que le clic sur la croix bufferline
    vim.api.nvim_create_user_command("Bd", function(opts)
      local bufnr = opts.args ~= "" and tonumber(opts.args)
        or vim.api.nvim_get_current_buf()
      close_buf(bufnr)
    end, { nargs = "?", desc = "Ferme un buffer sans perdre la fenêtre" })

    -- <leader>bd → raccourci rapide
    vim.keymap.set("n", "<leader>bd", function()
      close_buf(vim.api.nvim_get_current_buf())
    end, { noremap = true, silent = true, desc = "Fermer le buffer courant" })

  end,
}