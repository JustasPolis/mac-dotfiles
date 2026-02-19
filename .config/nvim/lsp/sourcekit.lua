return {
	cmd = {
		"sourcekit-lsp",
	},
	filetypes = {
		"swift",
	},
	root_markers = {
		".git",
		"Package.swift",
		"*.xcodeproj",
		"*.xcworkspace",
	},
	on_init = function(client)
		client.server_capabilities.diagnosticProvider = {
			interFileDependencies = false,
			workspaceDiagnostics = true,
		}
	end,
	single_file_support = true,
	on_attach = function(_, _)
		---@diagnostic disable-next-line: duplicate-set-field
		vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
	end,
	log_level = vim.lsp.protocol.MessageType.Warning,
}
