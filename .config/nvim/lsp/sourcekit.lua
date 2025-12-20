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
		-- this removes diagnostics delays
		--client.server_capabilities.diagnosticProvider = {
		--	interFileDependencies = true,
		--	workspaceDiagnostics = false,
		--}
	end,
	single_file_support = true,
	on_attach = function(client, _)
		---@diagnostic disable-next-line: duplicate-set-field
		--vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
	end,
	log_level = vim.lsp.protocol.MessageType.Warning,
}
