----------------------------------------------------------------------
-- WHENEVER YOU MODIFY THIS FILE, START NVIM AND RUN :PackerCompile --
----------------------------------------------------------------------
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require("packer").startup(function(use)
    use "wbthomason/packer.nvim"

    -- look "n" feel
    use {
        "rebelot/kanagawa.nvim",
        config = function()
            vim.cmd "colorscheme kanagawa"
        end
    }
    use {
        "ojroques/nvim-hardline",
        config = function()
            require("hardline").setup {
                theme = "nordic",
            }
        end
    }

    -- do stuff with matching elements
    use "tpope/vim-surround"

    -- git stuff
    use "tpope/vim-fugitive"
    use {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end
    }

    -- file explorer
    use {
        "nvim-tree/nvim-tree.lua",
        requires = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup {
                view = {
                    width = 50,
                },
            }

            vim.api.nvim_set_keymap("n", "<Leader>t", ":NvimTreeToggle<CR>", { silent = true, noremap = true })
        end
    }

    -- finder
    use {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.0",
        requires = {{"nvim-lua/plenary.nvim"}},
        config = function()
            vim.api.nvim_set_keymap("n", "<C-p>", ":Telescope find_files<CR>", { silent = true, noremap = true })
        end
    }

    -- easymotion (consider switching to phaazon/hop.nvim)
    use {
        "easymotion/vim-easymotion",
        config = function()
            vim.g.EasyMotion_smartcase = 1
        end
    }

    -- syntax highlighting
    use "nvim-treesitter/nvim-treesitter"
    use "sheerun/vim-polyglot"

    if packer_bootstrap then
        require("packer").sync()
    end
end)
