return {
    {
        dir = "/Users/justaspolikevicius/job/lua-acp",
        name = "acp.nvim",
        cmd = { "AcpChat", "AcpChatClose", "AcpChatSubmit" },
        config = function()
            local opencode_config = {}
            if vim.env.OPENCODE_CONFIG_CONTENT and vim.env.OPENCODE_CONFIG_CONTENT ~= "" then
                local ok, decoded = pcall(vim.json.decode, vim.env.OPENCODE_CONFIG_CONTENT)
                if ok and type(decoded) == "table" then
                    opencode_config = decoded
                end
            end

            opencode_config = vim.tbl_deep_extend("force", opencode_config, {
                mcp = {
                    xcode = {
                        enabled = false,
                    },
                },
            })

            require("acp").setup({
                command = "opencode",
                args = { "acp" },
                env = {
                    OPENCODE_CONFIG_CONTENT = vim.json.encode(opencode_config),
                },
            })
        end,
    },
}
