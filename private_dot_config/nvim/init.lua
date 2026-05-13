-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^5", -- Remove version tracking to elect for nightly AstroNvim
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here with the `import` key
      mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
      icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
      pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
      update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
    },
  },
  {
    "AstroNvim/astrocommunity",
    { import = "astrocommunity.pack.gleam" },
    { import = "astrocommunity.pack.lua" },
    { import = "astrocommunity.pack.python" },
    { import = "astrocommunity.pack.rust" },
    { import = "astrocommunity.pack.sql" },
    { import = "astrocommunity.pack.terraform" },
    { import = "astrocommunity.pack.toml" },
    { import = "astrocommunity.colorscheme" },
    { import = "astrocommunity.editing-support.cloak-nvim" },
  },
  {
    "AstroNvim/astroui",
    opts = {
      colorscheme = "gruvbox",
    },
    icons = {
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
  {
    "AstroNvim/astrolsp",
    opts = {
      features = {
        codelens = true, -- enable/disable codelens refresh on start
        inlay_hints = true, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
      },
      formatting = {
        format_on_save = {
          enabled = false,
        },
      },
      autocmds = {
        lsp_codelens_refresh = {
          cond = "textDocument/codeLens",
          {
            event = { "InsertLeave", "BufEnter" },
            desc = "Refresh codelens (buffer)",
            callback = function(args)
              if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
            end,
          },
        },
      },
    },
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = function(_, opts)
      opts.scroll = { animate = { easing = "outQuad" } }
      opts.scope = {
        treesitter = {
          injections = false, -- workaround for nvim 0.12 bug: nil node in injection query crashes get_range()
        },
      }
      return opts
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
  { "Bekaboo/deadcolumn.nvim" },
  -- aerial.nvim crashes on Neovim 0.12 because TSNode:start() and :end_() were
  -- deprecated and removed. aerial uses them in backends/treesitter/helpers.lua.
  -- Removing treesitter from the backend list prevents the crash; LSP (the default
  -- first backend) covers most filetypes anyway. The only loss is symbol outline
  -- for files that have no LSP server attached.
  -- Remove this override once stevearc/aerial.nvim#513 is merged and released.
  {
    "stevearc/aerial.nvim",
    opts = { backends = { "lsp", "markdown", "man" } },
  },
  -- { import = "plugins" }, -- for system specific plugins
}, {
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
})

-- load custom snippets on first insert (LuaSnip is lazy, not available until then)
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    require("luasnip.loaders.from_vscode").load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
  end,
})

-- polish
vim.cmd "set mouse="
vim.opt.rnu = false
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 999
vim.opt.colorcolumn = "121"

-- snippet picker
vim.keymap.set({ "n", "i" }, "<leader>fs", function()
  local ls = require "luasnip"
  local ft = vim.bo.filetype
  local snips = vim.list_extend(vim.list_slice(ls.get_snippets(ft)), ls.get_snippets "all")
  if vim.tbl_isempty(snips) then
    vim.notify("No snippets for filetype: " .. ft, vim.log.levels.WARN)
    return
  end
  Snacks.picker.pick {
    title = "Snippets (" .. ft .. ")",
    items = vim.tbl_map(function(s)
      return { text = s.trigger .. " " .. (s.name or s.trigger), trigger = s.trigger, name = s.name or s.trigger, snippet = s }
    end, snips),
    format = function(item)
      return { { item.trigger, "Keyword" }, { "  " .. item.name, "Comment" } }
    end,
    preview = function(ctx)
      ctx.preview:reset()
      local ok, docstring = pcall(function() return ctx.item.snippet:get_docstring() end)
      if not ok or not docstring then
        ctx.preview:notify("no preview available", "warn")
        return
      end
      local lines = type(docstring) == "string"
        and vim.split(docstring, "\n", { plain = true })
        or docstring
      ctx.preview:set_lines(lines)
      ctx.preview:highlight({ ft = ft })
    end,
    confirm = function(picker, item)
      picker:close()
      vim.schedule(function()
        if vim.api.nvim_get_mode().mode ~= "i" then vim.cmd "startinsert" end
        vim.schedule(function() ls.snip_expand(item.snippet) end)
      end)
    end,
  }
end, { desc = "Find snippets" })

-- transparency
vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]
