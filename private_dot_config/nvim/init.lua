require "plugin"

-- handy mapping function
local kmap = function(mode, key, result)
    vim.api.nvim_set_keymap(mode, key, result, {
        noremap = true,
        silent = true
    })
end

-- use space as the leader
vim.g.mapleader = " "

-- better vertical nav
kmap("n", "j", "gj")
kmap("n", "k", "gk")

-- setup options
vim.opt.autoindent = true
vim.opt.backup = false
vim.opt.errorbells = false
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.incsearch = true
vim.opt.shiftwidth = 4
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.swapfile = false
vim.opt.syntax = "on"
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.scrolloff = 999
vim.opt.mouse = ""
