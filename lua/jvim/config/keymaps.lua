local cmd = vim.cmd
local exec = require('jvim.lib.exec')

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

return {
  -- NORMAL
  n = {
    -- Common
    ['<C-n>'] = { '<cmd>Neotree toggle<cr>', { desc = 'Toggle nvim-tree' } },
    ['<leader>e'] = { cmd.Neotree, { desc = 'Focus nvim-tree' } },
    ['<leader>q'] = { cmd.qall, { desc = 'Quit all' } },
    ['<leader>Q'] = { '<cmd>qall!<cr>', { desc = 'Quit no save' } },
    ['<leader>la'] = { '<cmd>Lazy<cr>', { desc = 'Open pkg manager' } },

    -- Buffer actions
    -- stylua: ignore start
    ['<leader>x'] = { JVim.buf.remove, { desc = 'Close buffer', nowait = true } },
    ['<leader>X'] = { '<cmd>Bdelete!<cr>', { desc = 'Close buffer without saving' }, },
    ['<leader>so'] = { '<cmd>w | so %<cr>', { desc = 'Save, source & run current config file' }, },
    ['<leader>y'] = { '<cmd>%y+<cr>', { desc = 'Copy whole buffer' } },
    ['<leader>v'] = { 'gg0vG$', { desc = 'Select whore buffer' } },
    -- stylua: ignore end

    -- Window actions
    ['<leader>z'] = { cmd.close, { desc = 'Close window', nowait = true } },
    ['<leader>ss'] = { cmd.vsplit, { desc = 'Vertical split' } },
    ['<leader>sh'] = { cmd.split, { desc = 'Horizontal split' } },
    ['<leader>re'] = { cmd.ZenMode, { desc = 'Toggle Zen mode' } },
    ['<C-S-Up>'] = { '<cmd>resize +2<cr>' },
    ['<C-S-Down>'] = { '<cmd>resize -2<cr>' },
    ['<C-S-Left>'] = { '<cmd>vertical resize -2<cr>' },
    ['<C-S-Right>'] = { '<cmd>vertical resize +2<cr>' },

    ['<leader>do'] = {
      function()
        local win = vim.api.nvim_get_current_win()
        local ln = vim.api.nvim_win_get_cursor(win)[1]
        vim.api.nvim_buf_set_lines(0, ln, ln, false, { '/**', '* ', '*/' })
        vim.cmd.normal('jj')
        vim.cmd('startinsert!')
      end,
      { desc = 'JSDoc' },
    },

    -- Centralization
    ['<leader>c'] = { 'zz', { nowait = true } },
    ['<C-d>'] = { '<C-d>zz' },
    ['<C-u>'] = { '<C-u>zz' },

    -- Git
    ['<leader>lg'] = { function() end, { desc = 'Lazygit' } },
    ['<leader>gd'] = { '<cmd>Gvdiffsplit<cr>', { desc = 'Git diff' } },
    ['<leader>cm'] = {
      function()
        vim.cmd('G add .')
        vim.cmd('G commit')
      end,
      { desc = 'Git commit' },
    },

    ['<leader>gc'] = {
      function()
        if require('copilot.client').is_disabled() then
          require('copilot.command').disable()
        else
          require('copilot.command').enable()
        end
      end,
      desc = { 'Toggle copilot' },
    },

    -- stylua: ignore start
    ['<leader>hr'] = { function() exec.hacky_reload() end, 'Hacky realod process (use with caution)' , },
    ['<leader>rl'] = { function() exec.run_last() end, 'Run last command' , },
    -- stylua: ignore end
  },

  -- INSERT
  i = {
    -- Exit insert mode
    ['jk'] = { '<ESC>', { nowait = true } },

    -- Navigate horizontally
    ['<C-h>'] = { '<Left>' },
    ['<C-l>'] = { '<Right>' },
  },

  -- VISUAL
  v = {
    -- Move selected block
    ['J'] = { "<cmd>m '>+1<CR>gv=gv" },
    ['K'] = { "<cmd>m '<-2<CR>gv=gv" },

    -- Stay in indent mode
    ['<'] = { '<gv' },
    ['>'] = { '>gv' },
  },
}
