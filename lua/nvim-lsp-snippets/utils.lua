local config = require('nvim-lsp-snippets.config')

---@class nvim_lsp_snippets.utils
local utils = {}

-- Log a debug message if verbose output is enabled
-- @param msg string The message to log
function utils.log_debug(msg)
    if config.get_option('verbose', false) then
        vim.notify(msg, vim.log.levels.DEBUG)
    end
end

--- Read the entire contents of a given file path as a string
--- @type fun(path: string): string | nil
function utils.read_entire_file(file_path)
    -- Try to open the file
    local file = io.open(file_path, 'r')
    if not file then
        vim.notify('Failed to open file \'' .. file_path .. '\' for read', vim.log.levels.ERROR)
        return nil
    end
    -- Read the entire contents of the file
    local file_contents = file:read('*a')
    -- Ensure the file is closed before return
    file:close()
    return file_contents
end

return utils
