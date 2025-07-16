-- bootstrap lazy.nvim, then use it to bootstrap astronvim
local lazypath = vim.env.LAZY or vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
	-- stylua: ignore
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
		lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
	-- stylua: ignore
	vim.api.nvim_echo(
		{ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } },
		true, {})
	vim.fn.getchar()
	vim.cmd.quit()
end

-- finally invoke lazy, install astronvim and setup custom stuff
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
		"AstroNvim/astrocommunity",
		{ import = "astrocommunity.pack.lua" },
		{ import = "astrocommunity.pack.rust" },
		{ import = "astrocommunity.pack.toml" },
		{ import = "astrocommunity.pack.python-ruff" },
		{ import = "astrocommunity.colorscheme.kanagawa-nvim" },
	},
	{
		"AstroNvim/astrolsp",
		opts = {
			formatting = {
				format_on_save = {
					enabled = false,
				},
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
							completion = {
								postfix = {
									enable = true,
								},
							},
						},
					},
				},
			},
		},
	},
	{
		"smoka7/hop.nvim",
		-- branch = "master",
		lazy = false,
		config = function()
			-- setup and config colours
			require("hop").setup({
				case_insensitive = true,
			})

			vim.cmd("hi HopNextKey guifg=#00ff00")
			vim.cmd("hi HopNextKey1 guifg=#00ff00")
			vim.cmd("hi HopNextKey2 guifg=#00a300")

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
	{
		"L3MON4D3/LuaSnip",
		config = function(plugin, opts)
			-- include the default astronvim config that calls the setup call
			require("astronvim.plugins.configs.luasnip")(plugin, opts)
			-- load snippets paths
			require("luasnip.loaders.from_vscode").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})
		end,
	},
	{
		"declancm/cinnamon.nvim",
		version = "*", -- use latest release
		opts = {
			keymaps = {
				basic = true,
				extra = true,
			},
		},
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
vim.cmd("set mouse=")
vim.opt.rnu = false
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 999

-- transparency
-- vim.cmd([[
--   highlight Normal guibg=none
--   highlight NonText guibg=none
--   highlight Normal ctermbg=none
--   highlight NonText ctermbg=none
-- ]])
