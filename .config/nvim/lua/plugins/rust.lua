return {
  "JustasPolis/rust.nvim",
  dev = true,
  dependencies = {
    {
      "mfussenegger/nvim-dap",
      config = function()
        local dap = require("dap")
        local buf = vim.api.nvim_create_buf(false, true)

        dap.defaults.fallback.terminal_win_cmd = function()
          return buf
        end

        require("panel").add({
          name = "Dap",
          module = {
            on_enter = function(winid)
              vim.api.nvim_win_set_buf(winid, buf)
            end,
            on_leave = function(winid)
              print("im leaving")
            end,
          },
        })
      end,
    },
  },
  cmd = "Cargo",
  lazy = true,
  config = function()
    require("rust").setup()
  end,
}
