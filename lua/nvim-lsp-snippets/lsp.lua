local utils = require('nvim-lsp-snippets.utils')
local snippets = require('nvim-lsp-snippets.snippets')

--- @class nvim_lsp_snippets.lsp
local lsp = {
}

--- Create a closure for an LSP server
local function create_lsp_server_job(filetype)
    local function lsp_server_job(dispatchers)
        utils.log_debug('Starting LSP server job')

        -- Gather all of the snippets for this filetype
        --- @type nvim_lsp_snippets.snippets.Snippet[]
        local filetype_snippets = {}
        if snippets.snippets_by_language['all'] then
            filetype_snippets = vim.tbl_extend('error', filetype_snippets, snippets.snippets_by_language['all'])
        end
        if snippets.snippets_by_language[filetype] then
            filetype_snippets = vim.tbl_extend('error', filetype_snippets, snippets.snippets_by_language[filetype])
        end

        -- Create a list of all potential snippets
        local completion_results = {}
        local trigger_characters = {}
        for _, snippet in ipairs(filetype_snippets) do
            -- Create the completion result
            table.insert(completion_results, {
                label = snippet.label,
                detail = snippet.description,
                kind = vim.lsp.protocol.CompletionItemKind['Snippet'],
                documentation = {
                    value = snippet.body,
                    kind = vim.lsp.protocol.MarkupKind.Markdown,
                },
                insertText = snippet.body,
                insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
                filterText = snippet.prefix

            })
            -- Keep a list of all possible trigger characters
            table.insert(trigger_characters, snippet.prefix:sub(1,1))
        end

        utils.log_debug('Trigger characters: ' .. table.concat(trigger_characters, ''))

        --- @class nvim_lsp_snippets.lsp.Server
        local server = {
            --- @type boolean Indicates wether the server has been requested to shutdown
            has_close_request = false,
        }

        --- Called when the server received a request
        --- @param method vim.lsp.protocol.Method The protocol method this request is
        function server.request(method, params, handler)
            if method == 'initialize' then
                utils.log_debug('LSP Server: initialize request')
                handler(nil, {
                    capabilities = {
                        completionProvider = {
                            triggerCharacters = trigger_characters,
                        }
                    }
                })
            elseif method == 'textDocument/completion' then
                utils.log_debug('LSP Server: completion request')
                handler(nil, completion_results)
            elseif method == 'shutdown' then
                utils.log_debug('LSP Server: shutdown request')
                handler(nil, nil)
            end
        end

        --- Called when the server is notified of an event
        function server.notify(method, _)
            if method == 'exit' then
                dispatchers.on_exit(0, 15)
            end
        end

        --- Called to query wether this server is in the process of shutting down
        function server.is_closing()
            return server.has_close_request
        end

        --- Request this server to be shut down
        function server.terminate()
            server.has_close_request = true
        end

        return server
    end
    return lsp_server_job
end

--- @class nvim_lsp_snippets.lsp.Client
--- @field client_id integer|nil The ID of the client
--- @field name string The unique name of this client
--- @field server_closure function The closure for our LSP server
local Client = {}

--- Try to create an lsp client and server if one isn't active already for this filetype
--- @param filetype string The filetype we are trying to create a client for
function lsp.try_create_lsp_client(filetype)

    utils.log_debug('Trying to create LSP client for ' .. filetype)

    -- Create our client
    --- @type nvim_lsp_snippets.lsp.Client
    local client = {
        client_id = nil,
        name = 'nvim-lsp-snippets.' .. filetype,
        server_closure = create_lsp_server_job(filetype)
    }

    -- Callback for the server job
    local dispatchers = {
        on_exit = function(code, signal)
            vim.notify('Server exited with code ' .. code .. ' and signal ' .. signal, vim.log.levels.ERROR)
        end,
    }

    -- Start the client of our LSP
    client.client_id = vim.lsp.start({
        name = client.name,
        cmd = client.server_closure,
        on_init = function(_client)
            utils.log_debug('Initialised LSP client \'' .. client.name .. '\'')
        end,
        on_exit = function(code, signal)
            vim.notify('LSP client exited with code ' .. code .. ' and signal ' .. signal, vim.log.levels.ERROR)
        end,
    }, dispatchers)
end

return lsp
