require("nvim-treesitter").install({
    "objc",
    "cpp",
    "go",
    "zig",
    "python",
    "rust",
    "tsx",
    "nix",
    "typescript",
    "javascript",
    "json",
    "regex",
    "bash",
    "yaml",
    "swift",
    "wit",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
        vim.treesitter.start(ev.buf)
    end,
})
