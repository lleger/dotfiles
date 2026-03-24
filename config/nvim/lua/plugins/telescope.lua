return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            {
                "<leader>ff",
                function()
                    require("telescope.builtin").find_files()
                end,
                desc = "Find files",
            },
            {
                "<leader>fg",
                function()
                    require("telescope.builtin").live_grep()
                end,
                desc = "Live grep",
            },
            {
                "<leader>fb",
                function()
                    require("telescope.builtin").buffers()
                end,
                desc = "Find buffers",
            },
            {
                "<leader>fh",
                function()
                    require("telescope.builtin").help_tags()
                end,
                desc = "Help tags",
            },
        },
        opts = {
            defaults = {
                layout_strategy = "horizontal",
                sorting_strategy = "ascending",
                prompt_prefix = "  ",
                selection_caret = "  ",
                file_ignore_patterns = {
                    "%.git/",
                    "node_modules/",
                },
            },
        },
    },
}
