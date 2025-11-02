-- we need this to highlight function call parameters
vim.api.nvim_create_autocmd("LspTokenUpdate", {
	group = vim.api.nvim_create_augroup("one_type_priority", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or client.name ~= "sourcekit" then
			return
		end -- only SourceKit
		local t = args.data.token
		if t.type == "function" then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.type.function.swift",
				{ priority = 150 }
			)
		end
	end,
})

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
		--client.server_capabilities.semanticTokensProvider = nil
		-- we use other diagnostics for sourcekit
		-- need to disable publishDiagnostics
		if client.name == "sourcekit" then
			---@diagnostic disable-next-line: duplicate-set-field
			vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
		end
	end,
	log_level = vim.lsp.protocol.MessageType.Warning,
}
