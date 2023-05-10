return {
  colorscheme = "astrodark",

  lsp = {
    formatting = {
      format_on_save = {
        enabled = false,
      },
    },
  },

  polish = function()
    vim.opt.rnu = false
    vim.opt.scrolloff = 999
    vim.opt.sidescrolloff = 999
  end,
}
