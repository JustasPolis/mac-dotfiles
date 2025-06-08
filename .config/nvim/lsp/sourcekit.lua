return {
	cmd = {
		"sourcekit-lsp",
	},
	filetypes = {
    "swift"
	},
	root_markers = {
		".git",
		"Package.swift",
	},
	single_file_support = true,
	log_level = vim.lsp.protocol.MessageType.Warning,
}
