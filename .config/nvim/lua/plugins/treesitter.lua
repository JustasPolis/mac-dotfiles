require("nvim-treesitter").install({
    "c",
    "objc",
    "cpp",
    "go",
    "lua",
    "zig",
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
    "swift",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
    end,
})
