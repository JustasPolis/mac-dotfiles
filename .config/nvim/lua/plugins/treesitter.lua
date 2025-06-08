return {
  "nvim-treesitter/nvim-treesitter",
  lazy = true,
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c",
        "cpp",
        "go",
        "lua",
        "python",
        "rust",
        "tsx",
        "nix",
        "typescript",
        "vimdoc",
        "vim",
        "javascript",
        "json",
        "regex",
        "bash",
        "markdown",
        "markdown_inline",
        "yaml",
        "swift"
      },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
    })
  end,
}
