---@class nvim_lsp_snippets.utils
local utils = {}

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
