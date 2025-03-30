---@class nvim_lsp_snippets
local nvim_lsp_snippets = {}

nvim_lsp_snippets.config = require('nvim-lsp-snippets.config')
nvim_lsp_snippets.snippets = require('nvim-lsp-snippets.snippets')
nvim_lsp_snippets.utils = require('nvim-lsp-snippets.utils')

--- Configure the plugin with an optional options table
--- @type fun(opts?: nvim_lsp_snippets.config.Options)
function nvim_lsp_snippets.setup(opts)

    -- Load the configuration from the user supplied options
    config = nvim_lsp_snippets.config.new(opts)

    -- Load all of the snippets from the supplied package files
    for _, package_path in ipairs(config.paths) do
        nvim_lsp_snippets.snippets.load_package_json(package_path)
    end

end

return nvim_lsp_snippets
