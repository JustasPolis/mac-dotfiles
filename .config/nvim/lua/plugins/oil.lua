return {
  "stevearc/oil.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>fb",
      mode = { "n", "x", "o" },
      function()
        require("oil").open()
      end,
      desc = "Flash",
    },
  },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      prompt_save_on_select_new_entry = false,
      experimental_watch_for_changes = false,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == ".." or name == ".git"
        end,
      },
      win_options = {
        wrap = true,
        winblend = 0,
      },
      keymaps = {
        ["<C-c>"] = false,
        ["q"] = "actions.close",
      },
    })
  end,
}
