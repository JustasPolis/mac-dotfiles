return {
  "JustasPolis/panel.nvim",
  dev = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  cmd = "VimEnter",
  keys = {
    {
      "<leader>pm",
      mode = { "n" },
      function()
        require("panel").navigate("Messages")
      end,
      desc = "PanelMessages",
    },
    {
      "<leader>pd",
      mode = { "n" },
      function()
        require("panel").navigate("Diagnostics")
      end,
      desc = "PanelDiagnostics",
    },
  },
  config = function()
    require("panel").setup({
      open_on_launch = true,
      initial_tab = "Messages",
      tabs = {
        { name = "Messages", module = "messages" },
        { name = "Diagnostics", module = "diagnostics" },
      },
    })
  end,
  lazy = false,
  priority = 998,
}
