return {
  "akinsho/bufferline.nvim",
  version = "*",
  lazy = true,
  event = "BufEnter",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local buffer_line = require("bufferline")
    buffer_line.setup({
      options = {
        mode = "buffers",
        style_preset = {
          buffer_line.style_preset.minimal,
          buffer_line.style_preset.no_italic,
          buffer_line.style_preset.no_bold,
        },
        themable = true,
        numbers = "ordinal",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = {
          style = "none",
        },
        buffer_close_icon = "",
        modified_icon = "",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        tab_size = 13,
        diagnostics = false,
        diagnostics_update_in_insert = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        show_tab_indicators = false,
        show_duplicate_prefix = true,
        always_show_bufferline = true,
        custom_filter = function(buf_number, _)
          if vim.bo[buf_number].filetype == "" then
            return false
          else
            return true
          end
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "",
            text_align = "left",
            separator = "",
          },
        },
      },
    })
  end,
}
