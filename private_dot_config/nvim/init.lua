-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

-- finally invoke lazy, and setup custom stuff
require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^4",
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here with the `import` key
      mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
      icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
      pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
    },
  },
  {
    "AstroNvim/astroui",
    opts = {
      colorscheme = "kanagawa",
    },
  },
  {
    "AstroNvim/astrolsp",
    opts = {
      features = {
        autoformat = false,
        inlay_hints = true,
      },
      config = {
        rust_analyzer = {
          settings = {
            -- Add clippy lints for Rust.
            ["rust-analyzer"] = {
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
            },
          },
        },
      },
    },
  },
  {
    "AstroNvim/astrocommunity",
    { import = "astrocommunity.pack.lua" },
    { import = "astrocommunity.pack.rust" },
    { import = "astrocommunity.pack.toml" },
    { import = "astrocommunity.pack.python-ruff" },
    { import = "astrocommunity.colorscheme.kanagawa-nvim", enabled = true },
  },
  {
    "smoka7/hop.nvim",
    -- branch = "master",
    lazy = false,
    config = function()
      -- setup and config colours
      require("hop").setup {
        case_insensitive = true,
      }

      vim.cmd "hi HopNextKey guifg=#00ff00"
      vim.cmd "hi HopNextKey1 guifg=#00ff00"
      vim.cmd "hi HopNextKey2 guifg=#00a300"

      -- bind to easymotion-like keys
      vim.api.nvim_set_keymap("n", "<Leader><Leader>b", "<cmd>HopWordBC<CR>", { noremap = true })
      vim.api.nvim_set_keymap("n", "<Leader><Leader>w", "<cmd>HopWordAC<CR>", { noremap = true })
      vim.api.nvim_set_keymap("n", "<Leader><Leader>j", "<cmd>HopLineAC<CR>", { noremap = true })
      vim.api.nvim_set_keymap("n", "<Leader><Leader>k", "<cmd>HopLineBC<CR>", { noremap = true })
      vim.api.nvim_set_keymap("v", "<Leader><Leader>w", "<cmd>HopWordAC<CR>", { noremap = true })
      vim.api.nvim_set_keymap("v", "<Leader><Leader>b", "<cmd>HopWordBC<CR>", { noremap = true })
      vim.api.nvim_set_keymap("v", "<Leader><Leader>j", "<cmd>HopLineAC<CR>", { noremap = true })
      vim.api.nvim_set_keymap("v", "<Leader><Leader>k", "<cmd>HopLineBC<CR>", { noremap = true })
    end,
  },
} --[[@as LazySpec]], {
  -- Configure any other `lazy.nvim` configuration options here
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
} --[[@as LazyConfig]])

-- polish
vim.cmd "set mouse="
vim.opt.rnu = false
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 999
