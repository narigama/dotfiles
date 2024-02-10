return {
  colorscheme = "kanagawa",

  plugins = {
    {
      "rebelot/kanagawa.nvim",
      name = "kanagawa",
      config = function()
        require("kanagawa").setup {}
      end,
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

        vim.cmd("hi HopNextKey guifg=#00ff00")
        vim.cmd("hi HopNextKey1 guifg=#00ff00")
        vim.cmd("hi HopNextKey2 guifg=#00a300")

        -- bind to easymotion-like keys
        vim.api.nvim_set_keymap("n", "<Leader><Leader>b", "<cmd>HopWordBC<CR>", {noremap=true})
        vim.api.nvim_set_keymap("n", "<Leader><Leader>w", "<cmd>HopWordAC<CR>", {noremap=true})
        vim.api.nvim_set_keymap("n", "<Leader><Leader>j", "<cmd>HopLineAC<CR>", {noremap=true})
        vim.api.nvim_set_keymap("n", "<Leader><Leader>k", "<cmd>HopLineBC<CR>", {noremap=true})
        vim.api.nvim_set_keymap("v", "<Leader><Leader>w", "<cmd>HopWordAC<CR>", {noremap=true})
        vim.api.nvim_set_keymap("v", "<Leader><Leader>b", "<cmd>HopWordBC<CR>", {noremap=true})
        vim.api.nvim_set_keymap("v", "<Leader><Leader>j", "<cmd>HopLineAC<CR>", {noremap=true})
        vim.api.nvim_set_keymap("v", "<Leader><Leader>k", "<cmd>HopLineBC<CR>", {noremap=true})
      end,
    }
  },

  lsp = {
    formatting = {
      format_on_save = {
        enabled = false,
      },
    },
  },

  polish = function()
    vim.cmd("set mouse=")
    vim.opt.rnu = false
    vim.opt.scrolloff = 999
    vim.opt.sidescrolloff = 999
  end,
}
