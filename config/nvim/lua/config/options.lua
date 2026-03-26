-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local site = vim.fn.stdpath("data") .. "/site/"
if not vim.tbl_contains(vim.api.nvim_list_runtime_paths(), site) then
  vim.opt.rtp:append(site)
end
