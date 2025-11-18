require("theme")
require("options")
require("lazy-nvim")
require("keymaps")
require("commands")
require("lsp")

-- Utility function to find buffer number by file path and fire textDocument/didOpen
-- local function open_lsp_buffer_for_file(filepath)
--    -- Normalize the file path
--    local normalized_path = vim.fn.fnamemodify(filepath, ":p")
--
--    -- Find existing buffer or create new one
--    local bufnr = vim.fn.bufnr(normalized_path)
--
--    if bufnr == -1 then
--    	-- Buffer doesn't exist, create it
--    	bufnr = vim.fn.bufadd(normalized_path)
--    	vim.fn.bufload(bufnr)
--    end
--
--    -- Get buffer contents
--    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
--    local content = table.concat(lines, "\n")
--
--    -- Get all active LSP clients for this buffer
--    local clients = vim.lsp.get_clients({ bufnr = bufnr })
--
--    if #clients == 0 then
--    	-- Try to attach LSP clients if none are attached
--    	vim.api.nvim_buf_call(bufnr, function()
--    		vim.cmd("do BufRead")
--    	end)
--    	clients = vim.lsp.get_clients({ bufnr = bufnr })
--    end
--
--    -- Send textDocument/didOpen notification to all clients
--    for _, client in ipairs(clients) do
--    	local params = {
--    		textDocument = {
--    			uri = vim.uri_from_bufnr(bufnr),
--    			languageId = vim.bo[bufnr].filetype,
--    			version = 0,
--    			text = vim.fn.join(vim.fn.readfile(normalized_path), "\n"),
--    		},
--    	}
--
--    	client.notify("textDocument/didOpen", params)
--    end
--
--    return bufnr
-- nd
--
-- pen_lsp_buffer_for_file(
--    "/Users/justaspolikevicius/job/podimo-app-ios/Podimo/Features/HomeFeed/Utilities/HomeFeedEntityService.swift"
--
