return {
	cmd = {
		"clangd",
	},
	filetypes = {
		"c",
		"cpp",
	},
	root_markers = {
		".git",
	},
	init_options = {
		--fallbackFlags = { "-std=c11", "-Iinclude" },
	},
	single_file_support = true,
	on_attach = function(client, _)
		client.server_capabilities.semanticTokensProvider = nil
	end,
	log_level = vim.lsp.protocol.MessageType.Warning,
}
