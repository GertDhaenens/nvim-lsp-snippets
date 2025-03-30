---@class nvim_lsp_snippets
local nvim_lsp_snippets = {}

nvim_lsp_snippets.config = require('nvim-lsp-snippets.config')
nvim_lsp_snippets.snippets = require('nvim-lsp-snippets.snippets')
nvim_lsp_snippets.utils = require('nvim-lsp-snippets.utils')
nvim_lsp_snippets.lsp = require('nvim-lsp-snippets.lsp')

--- Configure the plugin with an optional options table
--- @type fun(opts?: nvim_lsp_snippets.config.Options)
function nvim_lsp_snippets.setup(opts)

    -- Load the configuration from the user supplied options
    config = nvim_lsp_snippets.config.new(opts)

    -- Load all of the snippets from the supplied package files into the snippet cache
    for _, package_path in ipairs(config.paths) do
        nvim_lsp_snippets.snippets.load_package_json(package_path)
    end

    -- Setup an auto command to spin up an LSP server per filetype
    vim.api.nvim_create_autocmd( { 'BufEnter' }, {
        desc = 'nvim-lsp-snippets',
        callback = function()
            -- Only create a client for buffers with a filetype
            if vim.bo.filetype ~= '' then
                nvim_lsp_snippets.lsp.try_create_lsp_client(vim.bo.filetype)
            end
        end
    })

end

return nvim_lsp_snippets
