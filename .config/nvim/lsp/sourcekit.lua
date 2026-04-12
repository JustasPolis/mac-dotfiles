local function has_xcode_workspace(dir)
    local handle = vim.uv.fs_scandir(dir)
    if not handle then
        return false
    end

    while true do
        local name, kind = vim.uv.fs_scandir_next(handle)
        if not name then
            return false
        end

        if kind == "directory" and (name:match("%.xcodeproj$") or name:match("%.xcworkspace$")) then
            return true
        end
    end
end

local function root_dir(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == "" then
        on_dir(nil)
        return
    end

    local dir = vim.fs.dirname(path)
    while dir do
        if vim.uv.fs_stat(vim.fs.joinpath(dir, "Package.swift")) or has_xcode_workspace(dir) then
            on_dir(dir)
            return
        end

        local parent = vim.fs.dirname(dir)
        if parent == dir then
            break
        end
        dir = parent
    end

    on_dir(vim.fs.root(path, { ".git" }))
end

return {
    cmd = {
        "sourcekit-lsp",
    },
    filetypes = {
        "swift",
    },
    root_dir = root_dir,
    on_init = function(client)
        client.server_capabilities.diagnosticProvider = {
            interFileDependencies = true,
            workspaceDiagnostics = false,
        }
    end,
    single_file_support = true,
    handlers = {},
    log_level = vim.lsp.protocol.MessageType.Warning,
}
