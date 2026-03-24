local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    group = vim.api.nvim_create_augroup("dotfiles-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
