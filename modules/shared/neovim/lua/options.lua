vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Enable true colors
vim.opt.termguicolors = true

-- Set line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Text wrapping settings
vim.opt.wrap = true                    -- Enable line wrapping
vim.opt.linebreak = true               -- Break at word boundaries
vim.opt.breakindent = true             -- Maintain indentation on wrapped lines
vim.opt.showbreak = "↳ "               -- Show wrap indicator
vim.opt.cpoptions:append("n")          -- Put showbreak in number column
vim.opt.smoothscroll = true            -- Smooth scrolling (Neovim 0.10+)

-- Folding settings (using treesitter)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99            -- Start with all folds open
vim.opt.foldenable = true
vim.opt.foldcolumn = "1"               -- Show fold column

-- Set indentation to 4 spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true

-- Auto-reload files when modified externally
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    pattern = "*",
    command = "checktime"
})

-- Better swap file handling
vim.opt.directory = vim.fn.stdpath("data") .. "/swap"
vim.opt.swapfile = true
vim.opt.updatetime = 300
vim.opt.updatecount = 10
