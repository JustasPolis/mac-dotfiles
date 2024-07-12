return {
	"stevearc/conform.nvim",
	lazy = true,
	opts = {
		formatters_by_ft = {
			swift = { "swiftformat" },
			lua = { "stylua" },
			rust = { "rustfmt" },
			go = { "gofmt" },
			sh = { "shfmt" },
			nix = { "alejandra" },
			scss = { "prettier" },
			css = { "prettier" },
			typescript = { "prettier" },
			javascript = { "prettier" },
			dart = { "dart_format" },
			python = { "black" },
			c = { "clang-format" },
			cpp = { "clang-format" },
		},
	},
	keys = {
		{
			"<leader>ff",
			mode = { "n", "x", "o" },
			function()
				require("conform").format({ timeout_ms = 500, lsp_fallback = true })
			end,
			desc = "Format File",
		},
	},
}
