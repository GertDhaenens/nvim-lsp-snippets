local utils = require('nvim-lsp-snippets.utils')

--- @class nvim_lsp_snippets.snippets
local snippets = {
    --- The loaded snippets by the source file they were loaded from
    --- @type { [string]: nvim_lsp_snippets.snippets.Snippet[] }
    snippets_by_source = {},
    --- The loaded snippets by the language they apply to
    --- @type { [string]: nvim_lsp_snippets.snippets.Snippet[] }
    snippets_by_language = {}
}

--- A snippet that has been loaded from disk
--- @class nvim_lsp_snippets.snippets.Snippet
--- @field label string The short form name of a snippet
--- @field description string The long form description form of a snippet
--- @field prefix string The text that will trigger the snippet completion
--- @field body string The text that will be replacing the snippet on completion
local Snippet = {}

--- Load snippets from a file
--- @param path string The path to the snippet file to load from
--- @returns nvim_lsp_snippets.snippets.Snippet[] An array of snippets that have been loaded
function snippets.load_snippets_from_file(path)
    utils.log_debug('Attempting to load \'' .. path .. '\'')

    -- Check to see if this file has already been loaded
    if snippets.snippets_by_source[path] then
        utils.log_debug('\'' .. path .. '\' was cached. Returning cached entries...')
        return snippets.snippets_by_source[path]
    end

    -- Create our cache entry table
    snippets.snippets_by_source[path] = {}

    -- Read the contents of our file
    local snippets_contents = utils.read_entire_file(path)
    if not snippets_contents then
        vim.notify('\'' .. path .. '\' has empty contents. Skipping...', vim.log.levels.WARNING)
        return nil
    end

    -- Decode our contents
    local snippets_json = vim.json.decode(snippets_contents)
    if not snippets_json then
        vim.notify('\'' .. path .. '\' failed to decode. Skipping...', vim.log.levels.WARNING)
        return nil
    end

    -- Create our snippets
    for label, desc in pairs(snippets_json) do

        -- Body can be more than one line - concatenate it to a single string
        local concatenated_body = desc.body
        if type(desc.body) == 'table' then
            concatenated_body = table.concat(desc.body, '\n')
        end

        -- TODO: Deal with the fact that there can be more than one prefix
        -- by creating a snippet *per* prefix to add to the list

        --- @type nvim_lsp_snippets.snippets.Snippet
        local snippet = {
            label = label,
            description = desc.description,
            prefix = desc.prefix,
            body = concatenated_body,
        }

        -- Add it to our list of snippets from this source
        table.insert(snippets.snippets_by_source[path], snippet)
    end

    return snippets.snippets_by_source[path]
end

--- Load snippets from a supplied package file and returns the amount of snippets laoded
--- @param path string A path to the package.json file to load
function snippets.load_package_json(path)
    utils.log_debug('Attempting to load \'' .. path .. '\'')

    -- Read the contents of the package file
    local package_contents = utils.read_entire_file(path)
    if not package_contents then
        vim.notify('\'' .. path .. '\' has empty contents. Skipping...', vim.log.levels.WARNING)
        return 0
    end

    -- Decode the contents as a json file
    local package_json = vim.json.decode(package_contents)
    if not package_json then
        vim.notify('\'' .. path .. '\' failed to decode. Skipping...', vim.log.levels.WARNING)
        return 0
    end

    -- Extract the table we care about from the package, which is only the snippets
    local snippets_json = vim.tbl_get(package_json, "contributes", "snippets")
    if not snippets_json then
        vim.notify('\'' .. path .. '\' failed fetch contributes.snippets from file. Skipping...', vim.log.levels.WARNING)
        return 0
    end

    -- Go over all of our snippets and cache them based on filetype
    for _, snippet_json in ipairs(snippets_json) do

        -- Language can be a table or a singly entry
        --- @type table<integer, string>
        local language_tbl = {}
        if type(snippet_json.language) == 'table' then
            for _, language in ipairs(snippet_json.language) do
                table.insert(language_tbl, language)
            end
        else
            table.insert(language_tbl, snippet_json.language)
        end

        -- Make the path relative to the package file
        local dir_name = vim.fs.dirname(path)
        local abs_path = vim.fs.normalize(vim.fs.joinpath(dir_name, snippet_json.path))

        -- Load the snippets from the source
        local loaded_snippets = snippets.load_snippets_from_file(abs_path)
        if not loaded_snippets then
            -- load_snippets_from_file will have thrown an error
            return 0
        end

        -- Insert the snippet into all of the language types
        for _, language in ipairs(language_tbl) do
            -- Create the table if we don't have one yet
            if not snippets.snippets_by_language[language] then
                snippets.snippets_by_language[language] = {}
            end
            for _, snippet in ipairs(loaded_snippets) do
                -- Add the snippets to the language table
                table.insert(snippets.snippets_by_language[language], snippet)
            end
        end
    end
end

return snippets
