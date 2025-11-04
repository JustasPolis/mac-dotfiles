vim.api.nvim_create_autocmd("LspTokenUpdate", {
	group = vim.api.nvim_create_augroup("one_type_priority", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
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
		if t.type == "class" then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.type.class.swift",
				{ priority = 150 }
			)
		end
		if t.type == "struct" then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.type.struct.swift",
				{ priority = 150 }
			)
		end
		if t.type == "variable" then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.type.variable.swift",
				{ priority = 150 }
			)
		end
		--if t.type == "method" and t.modifiers and t.modifiers.static then
		--	vim.lsp.semantic_tokens.highlight_token(
		--		t,
		--		args.buf,
		--		args.data.client_id,
		--		"@lsp.typemod.method.static.swift",
		--		{ priority = 170 }
		--	)
		--end
		if t.type == "property" and t.modifiers and t.modifiers.defaultLibrary then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.typemod.property.defaultLibrary.swift",
				{ priority = 160 }
			)
		end
		if t.type == "property" then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.type.property.swift",
				{ priority = 150 }
			)
		end
		if t.type == "keyword" then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.type.keyword.swift",
				{ priority = 150 }
			)
		end
		if t.type == "enumMember" then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.type.enumMember.swift",
				{ priority = 150 }
			)
		end

		if t.type == "method" and t.modifiers and t.modifiers.defaultLibrary then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.typemod.method.defaultLibrary.swift",
				{ priority = 130 }
			)
		end
		if t.type == "function" and t.modifiers and t.modifiers.defaultLibrary then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.typemod.function.defaultLibrary.swift",
				{ priority = 160 }
			)
		end
		if t.type == "function" and t.modifiers and t.modifiers.defaultLibrary then
			vim.lsp.semantic_tokens.highlight_token(
				t,
				args.buf,
				args.data.client_id,
				"@lsp.typemod.function.defaultLibrary.swift",
				{ priority = 160 }
			)
		end
		--if t.modifiers and t.modifiers.static then
		--	vim.lsp.semantic_tokens.highlight_token(
		--		t,
		--		args.buf,
		--		args.data.client_id,
		--		"@lsp.mod.property.static.swift",
		--		{ priority = 170 }
		--	)
		--end
		--vim.lsp.semantic_tokens.highlight_token(
		--	t,
		--	args.buf,
		--	args.data.client_id,
		--	"@lsp.typemod.function.defaultLibrary.swift",
		--	{ priority = 150 }
		--)
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
		if client.name == "sourcekit" then
			---@diagnostic disable-next-line: duplicate-set-field
			vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
		end
	end,
	log_level = vim.lsp.protocol.MessageType.Warning,
}
