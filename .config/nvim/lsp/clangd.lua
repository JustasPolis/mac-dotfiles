return {
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	cmd = {
		"clangd",
		"--background-index",
		"--completion-style=detailed",
		"--header-insertion=never",
	},
	root_markers = {
		".git",
	},
	single_file_support = true,
	on_attach = function(client, _)
		client.server_capabilities.semanticTokensProvider = nil
	end,
	log_level = vim.lsp.protocol.MessageType.Warning,
}
