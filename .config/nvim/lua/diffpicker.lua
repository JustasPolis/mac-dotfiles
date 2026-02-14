local NuiTree = require("nui.tree")
local NuiLine = require("nui.line")
local NuiSplit = require("nui.split")

local M = {}

---@class DiffItem
---@field filename string
---@field lnum number
---@field text string
---@field children? DiffItem[]

-- Sample nested data
local sample_data = {
  {
    filename = "src/",
    text = "Source files",
    children = {
      { filename = "main.lua", lnum = 10, text = "Fix this bug" },
      { filename = "utils.lua", lnum = 25, text = "Check logic here" },
      {
        filename = "components/",
        text = "UI Components",
        children = {
          { filename = "button.lua", lnum = 5, text = "Add hover state" },
          { filename = "input.lua", lnum = 42, text = "Validate input" },
        },
      },
    },
  },
  {
    filename = "tests/",
    text = "Test files",
    children = {
      { filename = "main_spec.lua", lnum = 15, text = "Add edge case test" },
    },
  },
}

---Build tree nodes recursively from data
---@param items DiffItem[]
---@param parent_id? string
---@return NuiTree.Node[]
local function build_nodes(items, parent_id)
  local nodes = {}
  for i, item in ipairs(items) do
    local id = (parent_id or "") .. "_" .. i
    local line = NuiLine()

    if item.children then
      -- Directory/group node
      line:append(" " .. item.filename, "Directory")
      line:append(" " .. item.text, "Comment")
    else
      -- File node
      line:append(" " .. item.filename, "Normal")
      if item.lnum then
        line:append(":" .. item.lnum, "LineNr")
      end
      line:append(" " .. item.text, "Comment")
    end

    local children = nil
    if item.children then
      children = build_nodes(item.children, id)
    end

    local node = NuiTree.Node({
      id = id,
      text = line,
      data = item,
    }, children)

    table.insert(nodes, node)
  end
  return nodes
end

---Open the tree picker in a horizontal split
---@param data? DiffItem[]
function M.open(data)
  data = data or sample_data

  local split = NuiSplit({
    relative = "editor",
    position = "bottom",
    size = "30%",
    buf_options = {
      buftype = "nofile",
      modifiable = false,
      readonly = true,
      filetype = "diffpicker",
    },
    win_options = {
      cursorline = true,
      number = false,
      relativenumber = false,
      signcolumn = "no",
      winhighlight = "Normal:Normal,WinSeparator:Normal",
    },
  })

  split:mount()

  -- Close on q or Esc
  split:map("n", "q", function()
    split:unmount()
  end, { noremap = true })
  split:map("n", "<Esc>", function()
    split:unmount()
  end, { noremap = true })

  local tree = NuiTree({
    winid = split.winid,
    nodes = build_nodes(data),
    prepare_node = function(node)
      local line = NuiLine()
      local depth = node:get_depth()
      local indent = string.rep("  ", depth - 1)

      -- Add expand/collapse indicator for nodes with children
      if node:has_children() then
        local icon = node:is_expanded() and "" or ""
        line:append(indent .. icon .. " ", "NonText")
      else
        line:append(indent .. "  ", "NonText")
      end

      -- Append the node content
      line:append(node.text)
      return line
    end,
  })

  -- Toggle expand/collapse on Enter or Tab
  split:map("n", "<CR>", function()
    local node = tree:get_node()
    if node and node:has_children() then
      if node:is_expanded() then
        node:collapse()
      else
        node:expand()
      end
      tree:render()
    elseif node and node.data and node.data.lnum then
      -- Jump to location if it's a file node
      split:unmount()
      local filename = node.data.filename
      vim.cmd("edit " .. filename)
      vim.api.nvim_win_set_cursor(0, { node.data.lnum, 0 })
    end
  end, { noremap = true })

  split:map("n", "<Tab>", function()
    local node = tree:get_node()
    if node and node:has_children() then
      if node:is_expanded() then
        node:collapse()
      else
        node:expand()
      end
      tree:render()
    end
  end, { noremap = true })

  -- Expand all with L
  split:map("n", "L", function()
    local updated = false
    for _, node in pairs(tree.nodes.by_id) do
      if node:has_children() and not node:is_expanded() then
        node:expand()
        updated = true
      end
    end
    if updated then
      tree:render()
    end
  end, { noremap = true })

  -- Collapse all with H
  split:map("n", "H", function()
    local updated = false
    for _, node in pairs(tree.nodes.by_id) do
      if node:has_children() and node:is_expanded() then
        node:collapse()
        updated = true
      end
    end
    if updated then
      tree:render()
    end
  end, { noremap = true })

  tree:render()
end

return M
