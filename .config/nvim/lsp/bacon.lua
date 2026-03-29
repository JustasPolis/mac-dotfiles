return {
    cmd = { "bacon-ls" },
    root_markers = { "Cargo.lock", "Cargo.toml" },
    filetypes = { "rust" },
    init_options = {
        updateOnSave = true,
        updateOnSaveWaitMillis = 1000,
    }
}
