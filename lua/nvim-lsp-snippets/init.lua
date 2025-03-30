local nvim_lsp_snippets = {}

nvim_lsp_snippets.config = require('config')

-- Configure the plugin with an optional options table
function nvim_lsp_snippets.setup(opts)

    -- Load the configuration from the user supplied options
    nvim_lsp_snippets.config.new(opts)

    -- TODO: Validate the configuration

end

return nvim_lsp_snippets
