return {
	cmd = { "rust-analyzer" },
	root_markers = { "Cargo.toml", "Cargo.lock", "rust-project.json", ".git" },
	filetypes = { "rust" },
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				enable = true,
			},
		},
	},
}
