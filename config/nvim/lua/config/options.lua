local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = ""
opt.showmode = false

opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 200
opt.timeoutlen = 300

opt.splitright = true
opt.splitbelow = true
opt.cursorline = true
opt.scrolloff = 4
opt.sidescrolloff = 8

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.completeopt = { "menu", "menuone", "noselect" }
opt.list = true
opt.listchars = {
    tab = "» ",
    trail = "·",
    nbsp = "␣",
}

opt.inccommand = "split"
opt.confirm = true
