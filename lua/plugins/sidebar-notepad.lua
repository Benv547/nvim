return {
  dir = vim.fn.stdpath("config") .. "/plugins/sidebar-notepad.nvim",
  name = "sidebar-notepad",
  lazy = false,
  config = function()
    require("sidebar-notepad").setup({
      width  = 45,
      keymap = "<leader>sb",
    })
  end,
}
