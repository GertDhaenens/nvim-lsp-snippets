---@class nvim_lsp_snippets.config
local config = {}

---@class nvim_lsp_snippets.config.Options : nvim_lsp_snippets.config.DefaultOptions
local C = {}

---@class nvim_lsp_snippets.config.DefaultOptions
local defaults = {
    --- Package.json files to load
    --- @type string[]
    paths = {
        vim.fn.stdpath('config') .. '/snippets/package.json'
    }
}

--- Create a new config based off of the defaults
--- @param opts nvim_lsp_snippets.config.Options The user supplied options
--- @return nvim_lsp_snippets.config.Options
function config.new(opts)
    C = vim.tbl_extend("force", {}, defaults, opts or {})
    return C
end

--- Get an option from the current configuration
--- @type fun(option: string, defaultValue?: any): any
function config.get_option(option, defaultValue)
    return C[option] or defaultValue
end

--- Set an option on the current configuration
--- @type fun(option: string, value: any)
function config.set_option(option, value)
    C[option] = value
end

return config
