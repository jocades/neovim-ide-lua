return {
  {
    'neovim/nvim-lspconfig',
    event = 'BufReadPre',
    dependencies = {
      'williamboman/mason.nvim', -- automatically install LSPs to stdpath for neovim
      'williamboman/mason-lspconfig.nvim', -- lspconfig setup (capabilites, on_attach, etc)
      { 'j-hui/fidget.nvim', config = true }, -- lsp status UI
      { 'folke/neoconf.nvim', cmd = 'Neoconf', config = true },
      { 'folke/neodev.nvim', opts = { experimental = { pathStrict = true } } }, -- additional lua configuration (neovim globals, require paths cmp, etc)
      { 'b0o/SchemaStore.nvim', version = false },
      'jose-elias-alvarez/typescript.nvim',
    },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        -- virtual_text = false, -- disable in-line text diagnostic
        virtual_text = { spacing = 4, prefix = '●' },
        severity_sort = true,
      },
      autoformat = true,
      format = {
        formatting_options = nil, -- handled by null-ls
        timeout_ms = nil,
      },
      -- Servers & Settings
      servers = {
        -- Python
        pyright = {
          settings = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              typeCheckingMode = 'basic',
            },
          },
        },
        -- ruff_lsp = {}, -- fast but missing a lof of features, like hover, etc.
        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        -- JSON
        jsonls = {
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas
              or {}
            vim.list_extend(
              new_config.settings.json.schemas,
              require('schemastore').json.schemas()
            )
          end,
          settings = {
            json = {
              format = { enable = true },
              validate = { enable = true },
            },
          },
        },
        -- TypeScript (handled by typescript.nvim)
        tsserver = {},
        -- Deno
        denols = {},
        -- C
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--completion-style=detailed',
            '--header-insertion=iwyu',
          },
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
            semanticHighlighting = true,
          },
        },
        -- Go
        gopls = {
          cmd = { 'gopls', 'serve' },
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
                shadow = true,
              },
              staticcheck = true,
            },
          },
        },
        -- Tailwind CSS
        tailwindcss = {},
        -- Astro Framework
        astro = {},
        -- Rust
        rust_analyzer = {},
        --- HTML
        html = {},
      },
    },
    config = function(_, opts)
      vim.diagnostic.config(opts.diagnostics)
      local capabilities = require('cmp_nvim_lsp').default_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )
      -- Fix clang formatter warnings
      capabilities.offsetEncoding = { 'utf-16' }

      local lsp_config = require('mason-lspconfig')

      lsp_config.setup({ ensure_installed = vim.tbl_keys(opts.servers) })

      lsp_config.setup_handlers({
        function(server_name)
          local setup = {
            capabilities = capabilities,
            on_attach = require('plugins.lsp.keymaps').on_attach,
          }

          if opts.servers[server_name].cmd ~= nil then
            setup.cmd = opts.servers[server_name].cmd
          end

          if opts.servers[server_name].settings ~= nil then
            setup.settings = opts.servers[server_name].settings
          end

          if opts.servers[server_name].init_options ~= nil then
            setup.init_options = opts.servers[server_name].init_options
          end

          if opts.servers[server_name].on_new_config ~= nil then
            setup.on_new_config = opts.servers[server_name].on_new_config
          end

          if server_name == 'denols' then
            setup.root_dir =
              require('lspconfig.util').root_pattern('deno.json', 'deno.jsonc')
            setup.init_options = { enable = true, unstable = true }
          elseif server_name == 'tsserver' then
            setup.root_dir =
              require('lspconfig.util').root_pattern('package.json')
            setup.single_file_support = false
          end

          require('lspconfig')[server_name].setup(setup)
        end,
      })

      -- astro filetype (maybe use ftdetect dir?)
      vim.filetype.add({
        extension = {
          astro = 'astro',
        },
      })
      -- mdx filetype
      vim.filetype.add({
        extension = {
          mdx = 'mdx',
        },
      })
      vim.treesitter.language.register('markdown', 'mdx')

      -- toggle inline text
      require('utils').map('n', '<leader>dt', function()
        opts.diagnostics.virtual_text = not opts.diagnostics.virtual_text
        vim.diagnostic.config(opts.diagnostics)
      end, { desc = 'LSP: Toggle inline text diagnostics' })
    end,
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    init = function() vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" end,
    opts = {
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
      formatters_by_ft = {
        lua = { 'stylua' },
        python = function(bufnr)
          if
            require('conform').get_formatter_info('ruff_format', bufnr).available
          then
            return { 'ruff_format' }
          else
            return { 'autopep8' }
          end
        end,
        javascript = { { 'prettierd', 'prettier' } },
        javascriptreact = { { 'prettierd', 'prettier' } },
        typescript = { { 'prettierd', 'prettier' } },
        typescriptreact = { { 'prettierd', 'prettier' } },
        sh = { 'shfmt' },
        c = { 'clang_format' },
        rust = { 'rustfmt' },
        go = { 'gofmt' },
      },
    },
    config = function(_, opts)
      require('conform').setup(opts)

      local f = require('conform').formatters
      f.stylua = {
        prepend_args = {
          '--config-path',
          vim.fn.stdpath('config') .. '/stylua.toml',
        },
      }
      f.autopep8 = { prepend_args = { '--max-line-length', '80' } }
      f.shfmt = { prepend_args = { '-i', '4' } }
      f.clang_format = { prepend_args = { '-style=file' } }
      f.gofmt = { prepend_args = { '-s', '-w', '-tabs=false', '-tabwidth=4' } }
      f.rustfmt = { prepend_args = { '--config', 'max_width=80' } }
    end,
  },

  -- Formatting
  -- {
  --   'jose-elias-alvarez/null-ls.nvim',
  --   event = 'BufReadPre',
  --   config = function()
  --     local b = require('null-ls').builtins
  --
  --     local ts_formatter = b.formatting.deno_fmt.with({
  --       extra_args = { '--no-semicolons', '--single-quote' },
  --     })
  --
  --     local root_dir = vim.fn.getcwd()
  --     local prettier_files = { '.prettierrc', 'prettier.config.js', 'main.py' }
  --
  --     for _, file in ipairs(prettier_files) do
  --       local prettier_config = root_dir .. '/' .. file
  --       if require('utils').file_exists(prettier_config) then
  --         ts_formatter = b.formatting.prettierd
  --         break
  --       end
  --     end
  --
  --     local sources = {
  --       ts_formatter,
  --       b.formatting.autopep8.with({
  --         extra_args = {
  --           '--max-line-length',
  --           '80',
  --           '--experimental',
  --         },
  --       }),
  --       -- b.formatting.ruff.with { extra_args = { '--config', vim.fn.stdpath('config') .. '/.ruff.toml' } },
  --       b.formatting.stylua.with({
  --         extra_args = {
  --           '--config-path',
  --           vim.fn.stdpath('config') .. '/stylua.toml',
  --         },
  --       }),
  --       b.formatting.shfmt.with({ extra_args = { '-i', '4' } }),
  --       b.diagnostics.shellcheck.with({ diagnostics_format = '#{m} [#{c}]' }),
  --       b.formatting.clang_format.with({ extra_args = { '-style=file' } }),
  --       b.formatting.gofmt.with({
  --         extra_args = { '-s', '-w', '-tabs=false', '-tabwidth=4' },
  --       }),
  --       b.formatting.rustfmt.with({
  --         extra_args = { '--config', 'max_width=80' },
  --       }),
  --     }
  --
  --     require('null-ls').setup({
  --       debug = true,
  --       sources = sources,
  --       on_attach = require('plugins.lsp.formatting').on_attach,
  --     })
  --   end,
  -- },

  -- LS manager
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    opts = {
      ensure_installed = {
        'prettierd',
        'autopep8',
        'stylua',
        'shellcheck',
        'shfmt',
        'flake8',
        'clangd',
      },
    },
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require('mason-registry')
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then p:install() end
      end
    end,
  },

  -- Better diagnostics lists
  {
    'folke/trouble.nvim',
    cmd = { 'TroubleToggle', 'Trouble' },
    opts = { use_diagnostic_signs = true },
  },
  { 'folke/lsp-colors.nvim', event = 'BufReadPre', config = true },

  -- Lsp symbol outline
  {
    'SmiteshP/nvim-navic',
    enabled = false,
    lazy = true,
    init = function()
      vim.g.navic_silence = true
      require('utils').on_attach(function(client, buffer)
        if client.server_capabilities.documentSymbolProvider then
          require('nvim-navic').attach(client, buffer)
        end
      end)
    end,
    opts = { separator = ' ', highlight = false, depth_limit = 5 },
  },
}
