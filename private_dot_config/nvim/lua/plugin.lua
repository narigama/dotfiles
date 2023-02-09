----------------------------------------------------------------------
-- WHENEVER YOU MODIFY THIS FILE, START NVIM AND RUN :PackerCompile --
----------------------------------------------------------------------
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

    -- look 'n' feel
    use {
        'rebelot/kanagawa.nvim',
        config = function()
            vim.cmd 'colorscheme kanagawa'
        end
    }

    use {
        'ojroques/nvim-hardline',
        config = function()
            require('hardline').setup {
                theme = 'nordic'
            }
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

            vim.keymap.set('n', '<Leader>t', ':NvimTreeToggle<CR>', {
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

    -- LSP
    use {
        'neovim/nvim-lspconfig',
        requires = {'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim', 'j-hui/fidget.nvim',
                    'folke/neodev.nvim'}
    }

    -- Autocompletion
    use {
        'hrsh7th/nvim-cmp',
        requires = {'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip'},

        config = function()
            local on_attach = function(_, bufnr)
                local nmap = function(keys, func, desc)
                    if desc then
                        desc = 'LSP: ' .. desc
                    end

                    vim.keymap.set('n', keys, func, {
                        buffer = bufnr,
                        desc = desc
                    })
                end

                nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
                nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
                nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
                nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

                -- See `:help K` for why this keymap
                nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
                nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

                -- Lesser used LSP functionality
                nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
                nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
                nmap('<leader>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, '[W]orkspace [L]ist Folders')

                -- Create a command `:Format` local to the LSP buffer
                vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
                    vim.lsp.buf.format()
                end, {
                    desc = 'Format current buffer with LSP'
                })
            end

            -- Enable the following language servers
            -- Add any additional override configuration in the following tables. They will be passed to
            -- the `settings` field of the server config. You must look up that documentation yourself.
            local servers = {
                ruff_lsp = {},
                pyright = {},
                rust_analyzer = {},
                sumneko_lua = {
                    Lua = {
                        workspace = {
                            checkThirdParty = false
                        },
                        telemetry = {
                            enable = false
                        }
                    }
                }
            }

            -- Setup neovim lua configuration
            require('neodev').setup()

            -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            -- Setup mason so it can manage external tooling
            require('mason').setup()

            -- Ensure the servers above are installed
            local mason_lspconfig = require 'mason-lspconfig'

            mason_lspconfig.setup {
                ensure_installed = vim.tbl_keys(servers)
            }

            mason_lspconfig.setup_handlers {
                function(server_name)
                    require('lspconfig')[server_name].setup {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers[server_name]
                    }
                end
            }

            -- Turn on lsp status information
            require('fidget').setup()

            -- nvim-cmp setup
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true
                    },
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, {'i', 's'}),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, {'i', 's'})
                },
                sources = {{
                    name = 'nvim_lsp'
                }, {
                    name = 'luasnip'
                }}
            }
        end
    }

    if packer_bootstrap then
        require('packer').sync()
    end
end)
