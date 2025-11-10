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
	on_init = function(client)
		-- this removes diagnostics delays
		client.server_capabilities.diagnosticProvider = {
			interFileDependencies = true,
			workspaceDiagnostics = false,
		}
	end,
	single_file_support = true,
	on_attach = function(client, _)
		-- we use other diagnostics for sourcekit
		-- need to disable publishDiagnostics to avoid duplicates
		client.server_capabilities.semanticTokensProvider = nil
		---@diagnostic disable-next-line: duplicate-set-field
		vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
	end,
	log_level = vim.lsp.protocol.MessageType.Warning,
}
