return {
	cmd = {
		"lua-language-server",
	},
	filetypes = {
		"lua",
	},
	root_markers = {
		".git",
		".luacheckrc",
		".luarc.json",
		".luarc.jsonc",
		".stylua.toml",
		"selene.toml",
		"selene.yml",
		"stylua.toml",
	},
	single_file_support = true,
	settings = {
		Lua = {
			diagnostics = {
				-- recognize the `vim` global:
				globals = { "vim" },
			},
			workspace = {
				-- make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false, -- disable prompting for third-party libs
			},
			telemetry = {
				enable = false, -- turn off telemetry
			},
		},
	},
	log_level = vim.lsp.protocol.MessageType.Warning,
}
