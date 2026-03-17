-- ========== basics ==========
vim.g.mapleader = " " -- space as leader
vim.wo.number = true

-- quick terminal split
vim.keymap.set('n', '<leader>D', function()
  vim.cmd('split | terminal')
end, { silent = true })

vim.keymap.set('n', '<leader>d', function()
  vim.cmd('vsplit | terminal')
end, { silent = true })

-- window nav
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- ========== lazy.nvim bootstrap ==========
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ========== plugins ==========
require("lazy").setup({
  { "nvim-lua/plenary.nvim", lazy = true },

  {"gbprod/yanky.nvim"},


  -- Telescope
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Telescope",
  keys = {
    -- File / grep
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep"  },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers"    },

    -- Your hidden/no-ignore grep (fixed + safe)
    {
      "<leader>fh",
      function()
        require("telescope.builtin").live_grep({
          additional_args = function()
            return { "--no-ignore", "--hidden" }
          end,
        })
      end,
      desc = "Live grep (hidden/no-ignore)",
    },

    -- LSP navigation via Telescope (go-to + usages)
    { "gd", function() require("telescope.builtin").lsp_definitions() end, desc = "Definition" },
    { "gr", function() require("telescope.builtin").lsp_references() end, desc = "References / usages" },
    { "gi", function() require("telescope.builtin").lsp_implementations() end, desc = "Implementation" },
    { "gy", function() require("telescope.builtin").lsp_type_definitions() end, desc = "Type definition" },

    -- Bonus: symbols
    { "<leader>ss", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Symbols (file)" },
    { "<leader>sS", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, desc = "Symbols (workspace)" },
  },
  opts = {
    defaults = {
      -- Optional: makes Telescope feel nicer
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
  },
},

  -- Treesitter
  {
"nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "python", "vim" },
      sync_install = false,
      auto_install = true,
      highlight = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-n>",
          node_incremental = "<C-n>",
          scope_incremental = "<C-s>",
          node_decremental = "<C-m>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- LSP + tooling
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "ruff", "ty", "cssls", "html", "vtsls" },
      })
    end,
  },

  {
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local caps = require("cmp_nvim_lsp").default_capabilities()
    
    vim.lsp.enable("ruff")
    vim.lsp.config("ty", { capabilities = caps })
    vim.lsp.enable("ty")
    
    vim.lsp.config("cssls", { capabilities = caps })
    vim.lsp.enable("cssls")
    
    vim.lsp.config("vtsls", { capabilities = caps })
    vim.lsp.enable("vtsls")
    
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format() end, { desc = 'Format current file' })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
  end,
  },

-- Completion (nvim-cmp)
{
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    -- LSP source
    "hrsh7th/cmp-nvim-lsp",

    -- Snippets
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",

    -- Nice-to-have sources
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Load VSCode-style snippets (friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<Esc>"] = cmp.mapping.abort(),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
      }),
    })
  end,
},

  -- Formatting & Linting
  { "mhartington/formatter.nvim", event = { "BufReadPost", "BufNewFile" } },
  { "mfussenegger/nvim-lint",     event = { "BufReadPost", "BufNewFile" } },

  -- Theme: catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- load before UI
    opts = {
      integrations = {
        telescope = { enabled = true },
        dropbar = { enabled = true, color_mode = true },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin-mocha")

      vim.api.nvim_set_hl(0, "LineNr", { fg = "#c6d0f5" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#f9e2af" })
    end,
  },

  -- Color picker/highlighter
  {
    "uga-rosa/ccc.nvim",
    event = "VeryLazy",
    opts = {
      highlighter = {
        auto_enable = true,
        lsp = true,
      },
    },
    config = function(_, opts)
      require("ccc").setup(opts)
      vim.keymap.set("n", "<leader>cp", "<cmd>CccPick<CR>", { desc = "Pick color" })
      vim.keymap.set("n", "<leader>ch", "<cmd>CccHighlighterToggle<CR>", { desc = "Toggle color highlights" })
    end
  },
}, {
  ui = { border = "rounded" },
})

