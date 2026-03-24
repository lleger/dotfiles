local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>quitall<CR>", { desc = "Quit all" })

map("n", "<leader>e", "<cmd>Ex<CR>", { desc = "Explore files" })

map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus left" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus down" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus up" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus right" })
