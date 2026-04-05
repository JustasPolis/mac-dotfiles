require("snacks").setup({
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
    picker = {
        formatters = {
            file = {
                filename_only = true,
            },
        },
        matcher = {
            fuzzy = true,
            ignorecase = true,
        },
        win = {
            input = {
                keys = {
                    ["<leader>p"] = { "focus_preview", mode = "n" },
                    ["<leader>l"] = { "focus_list", mode = "n" },
                },
            },
            list = {
                keys = {
                    ["<leader>p"] = { "focus_preview", mode = "n" },
                    ["<leader>i"] = { "focus_input", mode = "n" },
                },
            },
            preview = {
                keys = {
                    ["<leader>l"] = { "focus_list", mode = "n" },
                    ["<leader>i"] = { "focus_input", mode = "n" },
                },
            },
        },
        sources = {
            buffers = {
                sort_lastused = false,
                layout = { fullscreen = true },
            },
            files = {
                git_status = false,
                layout = { fullscreen = true },
            },
            grep = {
                layout = { fullscreen = true },
            },
            explorer = {
                enter = true,
                focus = "input",
                diagnostics = false,
                git_status = false,
                layout = { fullscreen = true },
                follow_file = true,
                tree = true,
                jump = { close = true },
                auto_close = true,
                win = {
                    input = {
                        keys = {
                            ["<C-c>"] = { "explorer_add", mode = { "n", "i" } },
                            ["<C-d>"] = { "explorer_del", mode = { "n", "i" } },
                        },
                    },
                },
            },
            lsp_incoming_calls = {
                layout = { fullscreen = true },
            },
            lsp_definitions = {
                layout = { fullscreen = true },
            },
            lsp_implementations = {
                layout = { fullscreen = true },
            },
            diagnostics = {
                enter = true,
                focus = "list",
                diagnostics = false,
                git_status = false,
                follow_file = true,
                tree = true,
                jump = { close = true },
                auto_close = true,
                layout = { fullscreen = true },
            },
        },
    },
})

vim.keymap.set("n", "<leader>fd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fh", function() Snacks.picker.highlights() end, { desc = "Highlights" })
vim.keymap.set("n", "<leader>fe", function() Snacks.explorer({ focus = "input" }) end, { desc = "File Explorer" })
vim.keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Search files" })
vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Grep" })
