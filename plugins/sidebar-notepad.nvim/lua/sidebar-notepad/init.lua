-- sidebar-notepad/lua/sidebar-notepad/init.lua
-- Plugin nvim : sidebar droite avec bloc-note + zone caméra

local M = {}

local state = {
  sidebar_open = false,
  cam_win  = nil,
  note_win = nil,
  note_buf = nil,
  cam_buf  = nil,
  note_file = nil,   -- chemin du fichier de notes courant
}

local config = {
  width = 45,
  keymap = "<leader>sb",
  note_filetype = "markdown",
  -- Dossier où sont stockés les fichiers de notes (un par projet)
  -- Par défaut : stdpath("data")/sidebar-notes/
  notes_dir = vim.fn.stdpath("data") .. "/sidebar-notes",
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
}

-- ── Persistance ───────────────────────────────────────────────────────────────

-- Transforme le cwd en un nom de fichier safe : /home/user/monprojet → home_user_monprojet.md
local function cwd_to_filename()
  local cwd = vim.fn.getcwd()
  -- Remplace les séparateurs et caractères spéciaux par des underscores
  local name = cwd:gsub("[/\\:]+", "_"):gsub("^_", "")
  return config.notes_dir .. "/" .. name .. ".md"
end

-- Assure que le dossier de notes existe
local function ensure_notes_dir()
  if vim.fn.isdirectory(config.notes_dir) == 0 then
    vim.fn.mkdir(config.notes_dir, "p")
  end
end

-- Sauvegarde le buffer de notes dans son fichier projet
local function save_note_buf()
  if not (state.note_buf and vim.api.nvim_buf_is_valid(state.note_buf)) then return end
  if not state.note_file then return end
  local lines = vim.api.nvim_buf_get_lines(state.note_buf, 0, -1, false)
  local f = io.open(state.note_file, "w")
  if f then
    f:write(table.concat(lines, "\n"))
    f:close()
  end
end

-- Charge (ou crée) le fichier de notes du projet courant dans un buffer
local function get_note_buffer()
  ensure_notes_dir()
  local note_file = cwd_to_filename()

  -- Si le buffer existe déjà ET correspond au même projet, on le réutilise
  if state.note_buf and vim.api.nvim_buf_is_valid(state.note_buf)
    and state.note_file == note_file then
    return state.note_buf
  end

  -- Sauvegarde l'ancien buffer si on change de projet
  save_note_buf()

  state.note_file = note_file

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "Lexique547>Notes: " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"))
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = config.note_filetype
  vim.bo[buf].modifiable = true

  -- Charge le fichier existant ou initialise avec un contenu par défaut
  if vim.fn.filereadable(note_file) == 1 then
    local lines = {}
    for line in io.lines(note_file) do
      table.insert(lines, line)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  else
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "# Notes — " .. project_name,
      "",
      "",
    })
  end

  -- Sauvegarde automatique à chaque modification
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = buf,
    callback = save_note_buf,
  })

  -- Sauvegarde aussi à la fermeture de Neovim
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("SidebarNotepadSave", { clear = true }),
    callback = save_note_buf,
  })

  state.note_buf = buf
  return buf
end

-- ── Buffers ───────────────────────────────────────────────────────────────────

local function get_cam_buffer()
  if state.cam_buf and vim.api.nvim_buf_is_valid(state.cam_buf) then
    return state.cam_buf
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "Lexique547>Camera")
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, config.cam_placeholder)
  vim.bo[buf].modifiable = false
  state.cam_buf = buf
  return buf
end

-- ── Layout ────────────────────────────────────────────────────────────────────

local function get_heights()
  local total = vim.o.lines - 2
  local cam_h = math.floor(total / 3)
  local note_h = total - cam_h
  return cam_h, note_h
end

local function style_cam_win(win)
  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.foldcolumn = "0"
  wo.wrap = false
  wo.cursorline = false
  wo.statusline = " 📷  Camera Feed"
  wo.winhighlight = "Normal:SidebarCam,SignColumn:SidebarCam,EndOfBuffer:SidebarCam"
  wo.winfixwidth = true
  wo.winfixheight = true
  wo.winfixbuf = true
end

local function style_note_win(win)
  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.foldcolumn = "0"
  wo.wrap = true
  wo.linebreak = true
  wo.cursorline = true
  wo.statusline = " 📝  Bloc-note"
  wo.winhighlight = "Normal:SidebarNote,SignColumn:SidebarNote,CursorLine:SidebarNoteCursor"
  wo.winfixwidth = true
  wo.winfixheight = true
  wo.winfixbuf = true
end

local function setup_highlights()
  vim.api.nvim_set_hl(0, "SidebarCam",       { bg = "#0a0a0a", fg = "#444444" })
  vim.api.nvim_set_hl(0, "SidebarNote",       { bg = "#1a1b26", fg = "#c0caf5" })
  vim.api.nvim_set_hl(0, "SidebarNoteCursor", { bg = "#24283b" })
end

local function is_open()
  return state.sidebar_open
    and state.cam_win  and vim.api.nvim_win_is_valid(state.cam_win)
    and state.note_win and vim.api.nvim_win_is_valid(state.note_win)
end

local function reapply_layout()
  if not is_open() then return end
  vim.o.equalalways = false
  local cam_h, note_h = get_heights()
  local width = config.width
  if vim.api.nvim_win_is_valid(state.cam_win) then
    vim.api.nvim_win_set_width(state.cam_win, width)
    vim.api.nvim_win_set_height(state.cam_win, cam_h)
  end
  if vim.api.nvim_win_is_valid(state.note_win) then
    vim.api.nvim_win_set_width(state.note_win, width)
    vim.api.nvim_win_set_height(state.note_win, note_h)
  end
end

local function open_sidebar()
  setup_highlights()
  vim.o.equalalways = false

  local cam_h, note_h = get_heights()

  local cam_win = vim.api.nvim_open_win(get_cam_buffer(), false, {
    split = "right", win = 0,
    width = config.width, height = cam_h,
  })
  style_cam_win(cam_win)

  local note_buf = get_note_buffer()
  local note_win = vim.api.nvim_open_win(note_buf, true, {
    split = "below", win = cam_win,
    width = config.width, height = note_h,
  })
  style_note_win(note_win)

  local line_count = vim.api.nvim_buf_line_count(note_buf)
  vim.api.nvim_win_set_cursor(note_win, { line_count, 0 })

  state.cam_win  = cam_win
  state.note_win = note_win
  state.sidebar_open = true

  vim.keymap.set("n", "q", function() M.toggle() end, {
    buffer = note_buf, noremap = true, silent = true, desc = "Fermer la sidebar",
  })

  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  vim.notify("Sidebar ouverte — projet : " .. project_name, vim.log.levels.INFO)
end

local function close_sidebar()
  save_note_buf()  -- sauvegarde explicite à la fermeture
  for _, win in ipairs({ state.note_win, state.cam_win }) do
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  state.cam_win  = nil
  state.note_win = nil
  state.sidebar_open = false
  vim.notify("Sidebar fermée", vim.log.levels.INFO)
end

-- ── API publique ──────────────────────────────────────────────────────────────

function M.reapply_layout()
  reapply_layout()
end

function M.toggle()
  if is_open() then close_sidebar() else open_sidebar() end
end

function M.focus_note()
  if is_open() then
    vim.api.nvim_set_current_win(state.note_win)
  else
    vim.notify("Sidebar fermée — ouvre-la d'abord avec " .. config.keymap, vim.log.levels.WARN)
  end
end

-- Retourne le chemin du fichier de notes du projet courant
function M.note_file()
  return cwd_to_filename()
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  setup_highlights()
  vim.o.equalalways = false

  vim.keymap.set("n", config.keymap, M.toggle, {
    noremap = true, silent = true, desc = "Toggle sidebar (bloc-note + caméra)",
  })

  vim.api.nvim_create_user_command("SidebarToggle", M.toggle,     { desc = "Toggle sidebar"  })
  vim.api.nvim_create_user_command("SidebarFocus",  M.focus_note, { desc = "Focus bloc-note" })
  vim.api.nvim_create_user_command("SidebarNoteFile", function()
    vim.notify("Note file: " .. M.note_file(), vim.log.levels.INFO)
  end, { desc = "Affiche le chemin du fichier de notes courant" })

  local group = vim.api.nvim_create_augroup("SidebarNotepad", { clear = true })

  -- Redimensionnement du terminal
  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function() vim.defer_fn(reapply_layout, 50) end,
  })

  -- Événements natifs nvim-tree
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "NvimTreeOpened", "NvimTreeClosed" },
    callback = function() vim.defer_fn(reapply_layout, 10) end,
  })

  -- Filet de sécurité filetype NvimTree
  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
    group = group,
    callback = function()
      if vim.bo.filetype == "NvimTree" then
        vim.defer_fn(function() vim.defer_fn(reapply_layout, 30) end, 30)
      end
    end,
  })

  -- Rechargement des notes si le répertoire de travail change (ex: :cd)
  vim.api.nvim_create_autocmd("DirChanged", {
    group = group,
    callback = function()
      if is_open() then
        -- Sauvegarde l'ancien projet et recharge pour le nouveau
        save_note_buf()
        state.note_buf = nil   -- force la recréation au prochain get_note_buffer()
        local note_buf = get_note_buffer()
        if vim.api.nvim_win_is_valid(state.note_win) then
          vim.api.nvim_win_set_buf(state.note_win, note_buf)
          local line_count = vim.api.nvim_buf_line_count(note_buf)
          vim.api.nvim_win_set_cursor(state.note_win, { line_count, 0 })
        end
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        vim.notify("Sidebar : notes rechargées pour " .. project_name, vim.log.levels.INFO)
      end
    end,
  })
end

return M