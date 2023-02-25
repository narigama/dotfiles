local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    -- theme
    use {
        'rebelot/kanagawa.nvim',
        config = function()
            vim.cmd 'colorscheme kanagawa'
        end
    }

    -- status line
    use {
        'ojroques/nvim-hardline',
        config = function()
            require('hardline').setup {
                theme = 'nordic'
            }
        end
    }

    -- commenting 
    use {
        'echasnovski/mini.nvim',
        config = function()
            require('mini.comment').setup()
        end
    }

    -- notifications
    use {
        'rcarriga/nvim-notify',
        config = function()
            vim.notify = require('notify')
            vim.notify.setup()
        end
    }

    -- utils
    use 'tpope/vim-surround' -- change brackets

    -- git stuff
    use {
        'tpope/vim-fugitive',
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    }

    -- file explorer
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {'nvim-tree/nvim-web-devicons'},
        config = function()
            require('nvim-tree').setup {
                view = {
                    width = 50
                }
            }

            vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', {
                silent = true
            })
        end
    }

    -- finder
    use {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.0',
        requires = {'nvim-lua/plenary.nvim'},
        config = function()
            vim.keymap.set('n', '<C-p>', ':Telescope find_files<CR>', {
                silent = true
            })
            vim.keymap.set('n', '<C-b>', ':Telescope buffers<CR>', {
                silent = true
            })
        end
    }

    -- easymotion (consider switching to phaazon/hop.nvim)
    use {
        'easymotion/vim-easymotion',
        config = function()
            vim.g.EasyMotion_smartcase = 1
        end
    }

    -- syntax highlighting
    use 'sheerun/vim-polyglot'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            pcall(require('nvim-treesitter.install').update {
                with_sync = true
            })
        end
    }

    -- TODO: Autocompletion
    use {
        'hrsh7th/nvim-cmp',
        requires = {'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path', 'hrsh7th/cmp-cmdline', 'hrsh7th/cmp-vsnip', 'hrsh7th/vim-vsnip'},
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                snippet = {
                    expand = function()
                        vim.fn["vsnip#anonymous"](args.body)
                    end
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                },
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'vsnip' },
                }, {
                    { name = 'buffer' },
                }),
            })
        end
    }

    -- LSP
    use {
        'neovim/nvim-lspconfig',
        requires = {'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim', 'j-hui/fidget.nvim', 'folke/neodev.nvim'},
        config = function()
            require("mason").setup()
            local lsp = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            local servers = {"pyright", "ruff_lsp", "rust_analyzer"}
            for _, server in pairs(servers) do
                lsp[server].setup { capabilities = capabilities }
            end
        end
    }

    if packer_bootstrap then
        require('packer').sync()
    end
end)
