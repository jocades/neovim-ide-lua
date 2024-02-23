local Path = require('lib.path')
local str = require('utils.str')
local event = require('nui.utils.autocmd').event
local Input = require('lib.plugins.ui.input')
local Menu = require('lib.plugins.ui.menu')
local Picker = require('lib.plugins.ui.picker')
local ts_utils = require('nvim-treesitter.ts_utils')

local DATA_PATH = '~/.local/data/notes'
local TEST = true

local M = {}

local root = TEST and Path('lua/lib/plugins/notes/test') or Path(DATA_PATH)

local test = root / 'test.md'
local calendar = root / 'calendar'

local augroup = vim.api.nvim_create_augroup('Notes', { clear = true })

-- ---
-- x: project name
-- y: meta
-- ---

---@param file P
local function getMetadata(file)
  local lines = file.readlines() -- -> { '---', 'x: project name', 'y: meta', '---' }
  local metadata = {}
  for i = 2, #lines - 1 do
    local line = lines[i]
    local key, value = line:match('(%w+):%s*(.+)')
    metadata[key] = value
  end
  return metadata
end

-- local metadata = getMetadata(root / 'test.md')

-- local dir = root / table.concat(str.split(metadata.x), '_')
--
-- if not dir.exists() then
--   dir.mkdir()
-- end

-- CALENDAR
-- add command like: :Today, to insert a new note with the current date

local function now()
  local date = os.date('*t')
  return {
    date = string.format('%d-%02d-%02d', date.year, date.month, date.day),
    time = string.format('%02d:%02d:%02d', date.hour, date.min, date.sec),
  }
end

---@param file P
local function find_links(file)
  -- find all the text inside [[other_file_name]]
  -- find all the files that are linked to the current file
  local links = {}
  for link in file.read():gmatch('%[%[(.-)%]%]') do
    table.insert(links, link)
  end

  return links
end

---@param path P | string
---@param opts? { start_insert: boolean }
local function open_note(path, opts)
  opts = opts or {}

  if type(path) == 'string' then
    path = Path(path)
  end

  -- escape the '$' char
  local cmd = string.format('%s/\\%s', path.parent().abs, path.name)
  vim.cmd.e(cmd)

  if opts.start_insert then
    vim.cmd('normal G$')
    vim.cmd('startinsert')
  end

  --[[ -- check for links when we save the file
  local id = vim.api.nvim_create_autocmd(event.BufWritePost, {
    group = augroup,
    pattern = path.abs,
    callback = function()
      -- find all the links in the current file
      local links = find_links(path)
      P(links)
    end,
  })

  -- remove the autocmd when the buffer is closed
  vim.api.nvim_create_autocmd(event.BufDelete, {
    group = augroup,
    pattern = path.abs,
    callback = function() vim.api.nvim_del_autocmd(id) end,
  }) ]]

  local buf = vim.api.nvim_get_current_buf()

  vim.keymap.set('n', '<leader>l', function()
    local node = ts_utils.get_node_at_cursor()

    if not node then
      print('No node found')
      return
    end

    print('type:', node:type())

    if node:type() == 'link_text' then
      node = node:parent()
      print('parent:', node:type())
    end

    if node:type() ~= 'shortcut_link' then
      print('Not a shortcut_link')
      return
    end

    local link = ts_utils.get_node_text(node)[1]

    print('link:', link)

    -- reomve the brackets
    link = link:gsub('%[', ''):gsub('%]', '') .. '.md'
    print('link:', link)

    local p = Path(calendar / now().date / link)
    print('path:', p)
    print('exists:', p.exists())
    open_note(p)

    -- ts_utils.update_selection(buf, node)
    -- local links = find_links(path)
    -- P(links)
  end, { buffer = buf })
end

--[[ local links = find_links(test)
P(links) ]]

local function generate_notename(number, title)
  return string.format('$%02d_%s.md', number, title)
end

local function is_note(pathname)
  return pathname:match('^%$%d+_.+%.md$') and true or false
end

local templates = {
  ---@param opts { name: string, ts: { date: string, time: string } }
  header = function(opts)
    return {
      '---',
      'title: ' .. opts.name,
      'date: ' .. opts.ts.date .. ' ' .. opts.ts.time,
      '---',
      '',
    }
  end,
  todo = {
    '# TODO:',
    '',
    '- [ ] Task',
  },
}

---@param title? string
---@param opts? { template: 'blank' | 'todo' }
local function create_note(title, opts)
  title = title or 'new note'
  opts = opts or {}

  local template = opts.template or 'blank'

  local ts = now()
  local today = calendar / ts.date

  local text = templates.header({ name = title, ts = ts })

  if template == 'todo' then
    table.extend(text, templates.todo)
  else
    table.insert(text, '')
  end

  -- if not exists then create the file with the first note
  if not today.exists() then
    today.mkdir({ parents = true })
    local file = today / generate_notename(1, title)
    file.write(text)
    open_note(file, { start_insert = true })
    return
  end

  local last
  for node in today.iterdir() do
    if is_note(node.name) then
      last = node
    end
  end

  local last_n = tonumber(last.name:match('(%d+)'))
  local file = today / generate_notename(last_n + 1, title)
  file.write(text)
  open_note(file, { start_insert = true })
end

---@return P[]
local function get_today_notes()
  local ts = now()
  local today = calendar / ts.date
  if not today.exists() then
    return {}
  end

  local notes = {}
  for node in today.iterdir() do
    if is_note(node.name) then
      table.insert(notes, node)
    end
  end

  return notes
end

---@param notes P[]
local function note_items(notes)
  local items = {}
  for _, note in ipairs(notes) do
    table.insert(items, { text = note.name, data = { path = note.abs } })
  end
  return items
end

---@param opts? { template: 'blank' | 'todo' }
function M.create_note_today(opts)
  opts = opts or {}
  local input = Input({
    title = 'Today',
    on_submit = function(value) create_note(value, opts) end,
  })
  input:mount()
  input:on(event.BufLeave, function() input:unmount() end)
end

function M.open_today_notes()
  Picker({
    title = "Today's notes",
    items = table.map(get_today_notes(), function(note) return note.name end),
    on_select = function(value) open_note(calendar / now().date / value) end,
    keymaps = {
      { 'n', 'n', function() M.create_note_today() end },
      { 'n', 'q', function() vim.cmd('q') end },
    },
  })

  -- local items = note_items(get_today_notes())
  --[[ local menu = Menu({
    title = 'Today ("n": new note)',
    items = items,
    on_submit = function(item)
      -- local path = calendar / now().date / item.text
      open_note(item.path)
    end,
  })
  menu:map('n', 'n', function()
    menu:unmount()
    M.create_note_today()
  end)
  menu:mount()
  menu:on(event.BufLeave, function() menu:unmount() end) ]]
end

function M.setup()
  if not root.exists() then
    root.mkdir({ parents = true })
  end

  vim.api.nvim_create_user_command('Today', function(opts)
    local command = (function()
      if opts.args == '' then
        return nil
      end
      return str.split(opts.args)
    end)()

    if not command then
      M.create_note_today()
      return
    end

    local args = table.reduce(command, function(acc, v)
      if v:sub(1, 1) ~= '-' then
        table.insert(acc, v)
      end
      return acc
    end, {})

    local options = table.reduce(command, function(acc, v)
      if v:sub(1, 1) == '-' then
        table.insert(acc, v)
      end
      return acc
    end, {})

    local title = #args == 0 and nil or args[1]

    create_note(title, {
      -- -t = todos template
      template = table.includes(options, '-t') and 'todo' or 'blank',
    })
  end, {
    nargs = '?',
  })
end

M.setup()

return M
