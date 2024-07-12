return {
  "neovim/nvim-lspconfig",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "folke/neodev.nvim",
      opts = {
        library = {
          plugins = false,
        },
        setup_jsonls = false,
      },
    },
    "nvim-telescope/telescope.nvim",
    "artemave/workspace-diagnostics.nvim",
  },
  config = function()
    local on_attach = function(client, bufnr)
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
      end

      vim.lsp.inlay_hint.enable(true)

      map("K", vim.lsp.buf.hover, "Hover Documentation")

      map("<leader>sd", function()
        local opts = {
          focusable = false,
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          border = "rounded",
          source = "always",
          prefix = " ",
          scope = "cursor",
        }
        vim.diagnostic.open_float(nil, opts)
      end, "LSP diagnostic hover")

      map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
      map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
      map("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
      map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]ereferences")

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, {
          border = "rounded",
        })

      vim.lsp.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
          update_in_insert = false,
          virtual_text = false,
        })
      require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities =
      vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

    require("lspconfig").rust_analyzer.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = { command = "clippy", extraArgs = { "--no-deps" } },
          diagnostics = { disabled = { "needless_return" }, experimental = { enable = true } },
        },
      },
    })

    require("lspconfig").clangd.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    require("lspconfig").gopls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        gopls = {
          completeUnimported = true,
          usePlaceholders = true,
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
      },
    })

    require("lspconfig").nil_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    require("lspconfig").cssls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      cmd = { "css-languageserver", "--stdio" },
    })

    require("lspconfig").dartls.setup({
      capabilities = capabilities,
      init_options = {
        onlyAnalyzeProjectsWithOpenFiles = false,
      },
      --autostart = false,
      single_file_support = false,
      on_attach = on_attach,
      settings = {
        dart = {
          completeFunctionCalls = true,
          showTodos = true,
          enableSnippets = true,
          analysisExcludedFolders = {
            "/home/justin/.pub-cache",
            "/nix/store",
          },
        },
      },
    })

    require("lspconfig").pyright.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    require("lspconfig").tsserver.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    require("lspconfig").zls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    require("lspconfig").lua_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          telemetry = {
            enable = false,
          },
          hint = {
            enable = true,
          },
          runtime = {
            version = "LuaJIT",
          },
          workspace = {
            maxPreload = 100000,
            preloadFileSize = 10000,
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file("", true),
          },
          completion = {
            callSnippet = "Replace",
            showParams = true,
          },
          diagnostics = { disable = { "missing-fields" }, delay = 1000, globals = { "vim" } },
        },
      },
    })
  end,
}
