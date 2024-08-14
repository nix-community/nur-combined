return {
  -- Autocompletion
  'hrsh7th/nvim-cmp',
  enabled = true,
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
--
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',

    -- Adds LSP completion capabilities
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',

    -- Adds a number of user-friendly snippets
    'rafamadriz/friendly-snippets',
  },
  config = function()
    local cmp = require'cmp'

    cmp.setup({
      snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      sources = cmp.config.sources({
        {
          name = 'buffer',
          option = {
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end
          },
        },
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
        }
      )
    })

  end,
}
