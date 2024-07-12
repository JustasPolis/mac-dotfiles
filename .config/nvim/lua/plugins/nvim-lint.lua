return {
	"mfussenegger/nvim-lint",
	opts = {},
	lazy = true,
	config = function()
		require("lint").linters.swiftlint = {
			name = "swiftlint",
			cmd = "swiftlint",
			stdin = true,
			append_fname = false,
			args = { "--reporter", "json", "--use-stdin", "--quiet" },
			stream = "stdout",
			ignore_exitcode = true,
			env = nil,
			parser = function(output, _)
				local severities = {
					Error = vim.diagnostic.severity.ERROR,
					Warning = vim.diagnostic.severity.WARN,
				}

				if output == "" then
					return {}
				end

				local decoded_output = vim.json.decode(output)

				if decoded_output == nil then
					return {}
				end

				local error = decoded_output[1]

				if error == nil or vim.tbl_isempty(decoded_output[1]) then
					return {}
				end

				local character = function()
					if error.character == nil or type(error.character) ~= "number" then
						return 0
					else
						return error.character - 1
					end
				end

				local line = function()
					if error.line == nil or type(error.line) ~= "number" then
						return -1
					else
						return error.line - 1
					end
				end

				local diagnostics = {}

				table.insert(diagnostics, {
					lnum = line(),
					col = character(),
					end_lnum = line(),
					end_col = character(),
					message = error.rule_id .. ": " .. error.reason,
					severity = assert(severities[error.severity], "missing mapping for severity " .. error.severity),
					source = "swiftlint",
				})

				return diagnostics
			end,
		}

		require("lint").linters_by_ft = {
			ts = { "eslint" },
			js = { "eslint" },
			tsx = { "eslint" },
			swift = { "swiftlint" },
			fish = { "fish" },
			nix = { "nix" },
		}
	end,
}
