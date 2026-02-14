return {
	cmd = {
		"emmylua_ls",
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
		".emmyrc.json",
	},
	single_file_support = true,
	settings = {
		Lua = {
			diagnostics = {
				-- recognize the `vim` global:
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false, -- turn off telemetry
			},
		},
	},
	on_attach = function(client, _)
		client.server_capabilities.semanticTokensProvider = nil
	end,
	log_level = vim.lsp.protocol.MessageType.Warning,
}
