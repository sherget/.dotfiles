return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local custom_theme = require'lualine.themes.ayu_dark'

        custom_theme.normal.a.bg = '#660000'
        custom_theme.normal.a.fg = '#ffffff'
        custom_theme.visual.a.bg = '#bf5000'
        custom_theme.visual.a.fg = '#ffffff'
        custom_theme.insert.a.bg = '#006c75'
        custom_theme.insert.a.fg = '#ffffff'
        custom_theme.inactive.c.bg = '#111111'
        custom_theme.normal.c.bg = '#111111'
        custom_theme.inactive.c.fg = '#999999'
        custom_theme.normal.c.fg = '#999999'

        require('lualine').setup({
            options = { theme = custom_theme }
        })
    end,
}
