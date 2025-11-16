return {
	cmd = { "rust-analyzer" },
	root_markers = { "Cargo.lock" },
	filetypes = { "rust" },
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				enable = true,
			},
		},
	},
}
