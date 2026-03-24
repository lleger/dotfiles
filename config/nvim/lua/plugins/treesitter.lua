return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        build = ":TSUpdate",
        opts = {
            auto_install = true,
            ensure_installed = {
                "bash",
                "css",
                "diff",
                "git_config",
                "git_rebase",
                "gitattributes",
                "gitcommit",
                "gitignore",
                "go",
                "gomod",
                "gosum",
                "html",
                "javascript",
                "json",
                "json5",
                "lua",
                "markdown",
                "markdown_inline",
                "nu",
                "query",
                "regex",
                "sql",
                "toml",
                "tsx",
                "typescript",
                "vim",
                "vimdoc",
                "yaml",
            },
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}
