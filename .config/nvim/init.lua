vim.g.python3_host_prog = '/usr/bin/python'
-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
        'git', 'clone', '--filter=blob:none',
        'https://github.com/echasnovski/mini.nvim', mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.nvim | helptags ALL')
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({path = {package = path_package}})

-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Basic options and global keybindings
now(function()
    vim.o.autoindent = true
    vim.o.expandtab = true
    vim.o.incsearch = true
    vim.o.number = true
    vim.o.shiftwidth = 4
    vim.o.smartindent = true
    vim.o.tabstop = 4
    vim.g.mapleader = '\\'
    -- alt+y to copy current selection to clipboard
    vim.keymap.set({'n', 'v'}, '<M-y>', '"+y', {desc = 'Copy to clipboard'})
    -- alt+p to paste
    vim.keymap.set({'n', 'v'}, '<M-p>', '"+p', {desc = 'Paste from clipboard'})
    -- source my init.lua
    vim.keymap.set('n', '<C-s>', '<CMD>source $MYVIMRC<cr>',
                   {desc = "Source init.lua"})
    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], {noremap = true})
end)

-- Autocommands that need to work immediately
now(function()
    -- Always use 2 space indent in these file types
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {"lua", "html", "js"},
        callback = function()
            vim.opt_local.shiftwidth = 2
            vim.opt_local.tabstop = 2
        end
    })
    -- Ansible filetype
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {"*ansible/*.yaml"},
        callback = function() vim.bo.filetype = "yaml_ansible" end

    })
    -- Better systemd unit syntax highlighting
    vim.api.nvim_create_autocmd({"BufEnter", "BufRead"}, {
        pattern = {
            "service", "socket", "device", "mount", "automount", "swap",
            "target", "path", "timer", "slice", "scope"
        },
        callback = function() vim.bo.filetype = "systemd" end
    })
end)

-- Theme
now(function()
    add({source = 'ellisonleao/gruvbox.nvim'})
    vim.o.termguicolors = true
    vim.o.background = "dark"
    require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
            strings = false,
            emphasis = false,
            comments = false,
            operators = false,
            folds = false
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = "hard", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false
    })
    vim.cmd('colorscheme gruvbox')
end)

-- [Mini](https://github.com/echasnovski/mini.nvim/tree/main) plugins
now(function() require('mini.basics').setup() end)
now(function()
    require('mini.notify').setup()
    vim.notify = require('mini.notify').make_notify()
end)
now(function() require('mini.icons').setup() end)
now(function() require('mini.tabline').setup() end)
now(function() require('mini.statusline').setup() end)

-- va( select outer ()
-- vi( select inner ()
later(function() require('mini.ai').setup() end)
later(function() require('mini.comment').setup() end)
later(function() require('mini.pairs').setup() end)
later(function() require('mini.pick').setup() end)
-- Add surrounding with sa (in visual mode or on motion).
-- Delete surrounding with sd.
-- Replace surrounding with sr.
-- Find surrounding with sf or sF (move cursor right or left).
-- Highlight surrounding with sh.
later(function() require('mini.surround').setup() end)
later(function()
    require('mini.files').setup()
    vim.keymap.set({'n'}, '<leader>t', function() MiniFiles.open() end,
                   {desc = 'Open MiniFiles tree'})
end)

-- External Plugins :help mini.deps
--
-- Treesitter
later(function()
    add({
        source = 'nvim-treesitter/nvim-treesitter',
        -- Use 'master' while monitoring updates in 'main'
        checkout = 'master',
        monitor = 'main',
        -- Perform action after every checkout
        hooks = {post_checkout = function() vim.cmd('TSUpdate') end}
    })
    require('nvim-treesitter.configs').setup({
        ensure_installed = {
            'lua', 'vimdoc', 'bash', 'python', 'yaml', 'markdown', 'json',
            'html', 'gitcommit', 'git_config', 'git_rebase', 'zig'
        },
        highlight = {enable = true}
    })
end)

-- Linting
later(function()
    add({source = 'mfussenegger/nvim-lint', checkout = 'master'})
    require('lint').linters_by_ft = {
        yaml_ansible = {'ansible-lint'},
        bash = {'shellcheck'},
        lua = {'luacheck'},
        python = {'ruff', 'mypy'},
        sh = {'shellcheck'},
        shell = {'shellcheck'},
        systemd = {'systemdlint'}
    }
    require('lint').linters.luacheck = {
        cmd = "luacheck",
        stdin = true,
        args = {"--globals", "vim", "lvim", "reload", "--"},
        stream = "stdout",
        ignore_exitcode = true,
        parser = require("lint.parser").from_errorformat("%f:%l:%c: %m",
                                                         {source = "luacheck"})
    }
    vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
        callback = function()
            -- try_lint without arguments runs the linters defined in `linters_by_ft`
            -- for the current filetype
            require("lint").try_lint()
        end
    })
    vim.diagnostic.config({virtual_text = true})
end)

-- Formatting
-- https://github.com/stevearc/conform.nvim
later(function()
    add({source = 'stevearc/conform.nvim', checkout = 'master'})
    require("conform").setup({
        formatters_by_ft = {
            lua = {"lua-format"},
            -- Conform will run multiple formatters sequentially
            python = {"ruff_format", "ruff_organize_imports"},
            -- You can customize some of the format options for the filetype (:help conform.format)
            zig = {"zigfmt"},
            bash = {"shfmt"}
        },
        format_on_save = {
            -- These options will be passed to conform.format()
            timeout_ms = 500,
            lsp_format = "fallback"
        }
    })
end)

