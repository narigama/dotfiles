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

    -- finder
    use {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.0",
        requires = {{"nvim-lua/plenary.nvim"}},
        config = function()
            vim.api.nvim_set_keymap("n", "<C-p>", ":Telescope find_files<CR>", {
                silent = true,
                noremap = true
            })
        end
    }

    -- syntax highlighting
    use "nvim-treesitter/nvim-treesitter"
    use "sheerun/vim-polyglot"

    if packer_bootstrap then
        require("packer").sync()
    end
end)
