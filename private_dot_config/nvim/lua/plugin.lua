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
    use 'wbthomason/packer.nvim'  -- keep packer up to date

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
            vim.g.nvim_tree_show_icons = false
            require('nvim-tree').setup {
                view = {
                    width = 50
                }
            }

            vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', { silent = true })
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

    -- autocomplete
    use { 'ms-jpq/coq.artifacts', branch = 'artifacts' }
    use { 'ms-jpq/coq.thirdparty', branch = '3p' }
    use { 'ms-jpq/coq_nvim', branch = 'coq' }

    -- LSP
    use {
        'neovim/nvim-lspconfig',
        requires = {'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim', 'j-hui/fidget.nvim', 'folke/neodev.nvim'},
        config = function()
            require("mason").setup()
            local coq = require('coq')
            local lsp = require('lspconfig')

            local servers = {
                pyright = {},
                ruff_lsp = {},
                rust_analyzer = {},
            }

            for server, config in pairs(servers) do
                lsp[server].setup(coq.lsp_ensure_capabilities(config))
            end

            vim.cmd([[COQnow -s]])
        end
    }

    if packer_bootstrap then
        require('packer').sync()
    end
end)
