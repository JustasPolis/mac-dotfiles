return {
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    cmd = {
        "vtsls",
        "--stdio",
    },
    root_markers = {
        "tsconfig.json",
        "jsconfig.json",
        "package.json",
        ".git",
    },
    init_options = {
        hostInfo = "neovim",
    },
    single_file_support = true,
}
