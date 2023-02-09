-- load all plugins
require "plugin"

-- use space as the leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- better vertical nav
vim.keymap.set({'n', 'v'}, '<Space>', '<Nop>', {
    silent = true
})
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", {
    expr = true,
    silent = true
})
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", {
    expr = true,
    silent = true
})

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- highlight selections
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
    pattern = '*'
})

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
vim.opt.signcolumn = 'yes'
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.swapfile = false
vim.opt.syntax = 'on'
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.wrap = false

