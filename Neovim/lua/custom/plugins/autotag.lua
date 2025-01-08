return {
    'windwp/nvim-ts-autotag',
    ft = {
        'html',
        'javascriptreact',
        'typescriptreact',
        'javascript',
        'typescript',
    },
    config = function()
        require('nvim-ts-autotag').setup()
    end,
}
