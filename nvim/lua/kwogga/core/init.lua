require("kwogga.core.options")
require("kwogga.core.keymaps")

local augroup = vim.api.nvim_create_augroup
local KwoggaGroup = augroup('Kwogga', {})

local autocmd = vim.api.nvim_create_autocmd
local YankGroup = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

autocmd('TextYankPost', {
    group = YankGroup,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({"BufWritePre"}, {
    group = KwoggaGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
