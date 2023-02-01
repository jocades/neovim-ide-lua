local present, comment = pcall(require, 'Comment')
if not present then
  return
end

comment.setup {
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),

  opleader = {
    line = '<C-/>',
    block = '<C-/>',
  },

  toggler = {
    line = '<C-/>',
    block = '<leader>cb',
  },
}
