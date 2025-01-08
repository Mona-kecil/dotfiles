return {
    'supermaven-inc/supermaven-nvim',
    config = function()
        require('supermaven-nvim').setup {
            keymaps = {
                accept_word = '<Tab>',
                clear_suggestion = '<C-]>',
            },
            disable_keymaps = false,
        }
    end,
}
