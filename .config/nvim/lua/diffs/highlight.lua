--- Highlight group definitions.
local M = {}

--- Apply all highlight groups.
--- @param overrides table<string, vim.api.keyset.highlight> User overrides
local function apply_highlights(overrides)
    local groups = {
        -- Diff highlights (reuse built-in diff groups)
        DifftAdded = { link = "DiffAdd" },
        DifftRemoved = { link = "DiffDelete" },
        DifftAddedFg = { link = "Added" },
        DifftRemovedFg = { link = "Removed" },
        DifftFiller = { link = "Comment" },
        -- Tree highlights
        DifftTreeFile = { link = "Normal" },
        DifftTreeRange = { link = "Comment" },
        DifftTreeCursorLine = { bg = "#353539" },
        DifftFileAdded = { fg = "#5f8f5f" },
        DifftFileDeleted = { fg = "#8f5f5f" },
    }

    for name, default in pairs(groups) do
        local hl = overrides[name] or default
        vim.api.nvim_set_hl(0, name, hl)
    end
end

--- Setup highlight groups with optional overrides.
--- @param overrides table<string, vim.api.keyset.highlight>|nil User overrides
function M.setup(overrides)
    overrides = overrides or {}

    apply_highlights(overrides)

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("DifftHighlights", { clear = true }),
        callback = function()
            apply_highlights(overrides)
        end,
    })
end

return M
