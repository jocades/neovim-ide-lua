return {
  'nvim-treesitter/nvim-treesitter',
  event = 'BufReadPre',
  -- build = function() -- auto install languages
  --   pcall(require('nvim-treesitter.install').update({ with_sync = true }))
  -- end,
  dependencies = {
    'nvim-treesitter/nvim-treesitter-refactor', -- refactorings
    'nvim-treesitter/nvim-treesitter-textobjects', -- additional text objects
    'nvim-treesitter/playground', -- treesitter playground
  },
  config = function()
    -- See `:help nvim-treesitter`
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'python',
        'typescript',
        'javascript',
        'tsx',
        'lua',
        'bash',
        'vim',
        'markdown',
        'markdown_inline',
        'json',
        'json5',
        'jsonc',
        'jsdoc',
        'yaml',
        'toml',
        'css',
        'html',
        'go',
        'rust',
        'c',
        'cpp',
        'diff',
        'astro',
      },
      auto_install = true,
      ignore_install = {},
      modules = {},
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true, disable = { 'python' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<c-backspace>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']C'] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[C'] = '@class.outer',
          },
        },
        -- swap = {
        --   enable = true,
        --   swap_next = {
        --     ['<leader>sp'] = '@parameter.inner',
        --   },
        --   swap_previous = {
        --     ['<leader>sP'] = '@parameter.inner',
        --   },
        -- },
      },
    })
  end,
}
