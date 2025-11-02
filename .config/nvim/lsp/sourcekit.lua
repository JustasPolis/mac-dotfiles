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
			interFileDependencies = true,
			workspaceDiagnostics = false,
		}
	end,
	single_file_support = true,
	flags = { debounce_text_changes = 0 },
	on_attach = function(client, _)
		client.server_capabilities.semanticTokensProvider = nil
		-- we use other diagnostics for sourcekit
		-- need to disable publishDiagnostics
		if client.name == "sourcekit" then
			---@diagnostic disable-next-line: duplicate-set-field
			vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
		end
	end,
	log_level = vim.lsp.protocol.MessageType.Warning,
}
