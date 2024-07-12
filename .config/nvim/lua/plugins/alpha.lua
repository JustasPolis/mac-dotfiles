return {
  "goolord/alpha-nvim",
  lazy = true,
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
    }

    dashboard.section.buttons.val = {
      dashboard.button("b", "   Browse Files", ":Telescope file_browser<CR>"),
      dashboard.button("f", "   Find Files", ":Telescope find_files<CR>"),
      dashboard.button("q", "   Quit", ":qa<CR>"),
    }
    alpha.setup(dashboard.config)
  end,
}
