return {
    cmd = {
        "emmylua_ls",
        "--editor",
        "neovim",
    },
    filetypes = {
        "lua",
    },
    root_markers = {
        ".emmyrc.json",
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "selene.toml",
        "selene.yml",
        "stylua.toml",
        ".git",
    },
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
}
