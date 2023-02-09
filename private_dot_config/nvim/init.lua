-- handy mapping function
kmap = function(mode, key, result)
    vim.api.nvim_set_keymap(mode, key, result, {
        noremap = true,
        silent = true
    })
end

-- load all plugins
require "plugin"

-- use space as the leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- better vertical nav
kmap("n", "j", "gj")
kmap("n", "k", "gk")

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- setup options
vim.opt.autoindent = true
vim.opt.backup = false
vim.opt.errorbells = false
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.incsearch = true
vim.opt.mouse = ""
vim.opt.number = true
vim.opt.scrolloff = 999
vim.opt.shiftwidth = 4
vim.opt.sidescrolloff = 999
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.swapfile = false
vim.opt.syntax = "on"
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.wrap = false

