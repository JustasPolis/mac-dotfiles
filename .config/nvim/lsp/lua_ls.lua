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
	log_level = vim.lsp.protocol.MessageType.Warning,
}
