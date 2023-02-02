require 'config.options'
require 'config.mappings'

return {
  -- Highlight, edit, and navigate code
  {
    'nvim-treesitter/nvim-treesitter',
    build = function() -- auto install languages
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-refactor', -- refactorings
      'nvim-treesitter/nvim-treesitter-textobjects', -- additional text objects
      'nvim-treesitter/playground', -- treesitter playground
    },
  },

  -- Fuzzy Finder (files, lsp, etc) + Plenary (common neovim lua utils)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'ahmedkhalf/project.nvim', -- telescope project picker
      'ThePrimeagen/harpoon', -- organize buffers
    },
  },
  { -- Telescope fzf native
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = vim.fn.executable 'make' == 1,
  },

  -- Snippets
  'L3MON4D3/LuaSnip', -- snippet engine
  'rafamadriz/friendly-snippets', -- a bunch of snippets to use

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'lewis6991/gitsigns.nvim',

  -- Copilot
  'github/copilot.vim',

  -- Terminal
  'akinsho/toggleterm.nvim',

  'kyazdani42/nvim-web-devicons', -- required by many other plugins
  -- Snazzy statusline, bufferline & file tree
  'nvim-lualine/lualine.nvim',
  'kyazdani42/nvim-tree.lua',
  'akinsho/bufferline.nvim',

  -- Custom home screen
  'goolord/alpha-nvim',

  { -- Keys helper
    'folke/which-key.nvim',
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require('which-key').setup {}
    end,
  },

  -- Misc --
  'folke/zen-mode.nvim', -- distraction free writing
  'moll/vim-bbye', -- better buffer deletion
  'NvChad/nvim-colorizer.lua', -- color highlighter
  'lukas-reineke/indent-blankline.nvim', -- add indentation guides even on blank lines
  'tpope/vim-sleuth', -- detect tabstop and shiftwidth automatically
  'lewis6991/impatient.nvim', -- speed up startup time
  --'p00f/nvim-ts-rainbow', -- colored parenthesis
  { 'iamcco/markdown-preview.nvim', build = 'cd app && yarn install', cmd = 'MarkdownPreview' }, -- markdown preview
}