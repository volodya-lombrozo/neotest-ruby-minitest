local vim = vim
local fn  = vim.fn
local cwd = fn.getcwd()

vim.opt.rtp:prepend(cwd)
vim.opt.rtp:prepend(cwd .. "/misc/plenary")
vim.opt.rtp:prepend(cwd .. "/misc/neotest")
vim.opt.rtp:prepend(cwd .. "/misc/nio")
vim.opt.rtp:prepend(cwd .. "/misc/nvim-treesitter")

-- Fail fast if plenary isn’t present
local ok = pcall(require, "plenary")
if not ok then
    error("Plenary not found on runtimepath. Run `make deps`.")
end

-- Fail fast if neotest isn’t present
ok = pcall(require, "neotest")
if not ok then
    error("Neotest not found on runtimepath. Run `make deps`.")
end

-- Fail fast if nio isn’t present
ok = pcall(require, "nio")
if not ok then
    error("Nio not found on runtimepath. Run `make deps`.")
end

-- Fail fast if nvim-treesitter isn’t present
ok = pcall(require, "nvim-treesitter")
if not ok then
    error("Nvim-treesitter not found on runtimepath. Run `make deps`.")
end

-- Load Ruby parsertest
require("nvim-treesitter.configs").setup({
  ensure_installed = "ruby",
  sync_install = true,
})

vim.opt.swapfile = false

