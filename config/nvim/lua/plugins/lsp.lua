return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            vim.diagnostic.config({
                severity_sort = true,
                float = { border = "rounded" },
                signs = true,
                underline = true,
                virtual_text = {
                    spacing = 2,
                    source = "if_many",
                },
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("dotfiles-lsp-attach", { clear = true }),
                callback = function(event)
                    local telescope = require("telescope.builtin")
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, {
                            buffer = event.buf,
                            desc = desc,
                        })
                    end

                    map("gd", telescope.lsp_definitions, "Goto definition")
                    map("gr", telescope.lsp_references, "Goto references")
                    map("gI", telescope.lsp_implementations, "Goto implementation")
                    map("<leader>ds", telescope.lsp_document_symbols, "Document symbols")
                    map("<leader>ws", telescope.lsp_dynamic_workspace_symbols, "Workspace symbols")
                    map("<leader>rn", vim.lsp.buf.rename, "Rename")
                    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("K", vim.lsp.buf.hover, "Hover")
                    map("gD", vim.lsp.buf.declaration, "Goto declaration")
                    map("<leader>f", function()
                        vim.lsp.buf.format({ async = true })
                    end, "Format buffer")
                end,
            })

            local servers = {
                bashls = {},
                gopls = {},
                jsonls = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                            diagnostics = {
                                globals = { "vim" },
                            },
                        },
                    },
                },
                nil_ls = {},
                nushell = {},
                ts_ls = {},
                yamlls = {},
            }

            for server, config in pairs(servers) do
                local ok = pcall(vim.lsp.config, server, config)
                if ok then
                    pcall(vim.lsp.enable, server)
                end
            end
        end,
    },
}
