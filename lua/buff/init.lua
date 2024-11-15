local Buff = {}
local Buffer = require('buff.buffer')
local Helpers = require('buff.helpers')
local Config = require('buff.config')
---@alias RuntimeGlobals {config: BuffConfig, buf: integer, win: integer, previous_win: integer, buffer_list: string[][], win_len: number }

---@type RuntimeGlobals
local Rt = {
    config = Config.get_config({}),
    buffer_list = {},
}

function Buff.toggle_buffer_list()
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    if Rt.buf == current_buffer then
        pcall(vim.api.nvim_win_close, Rt.win, true)
        return
    end

    Rt.buffer_list = {}
    local buffers = vim.api.nvim_list_bufs()
    local max_len = 10
    local cwd = vim.fn.getcwd()
    local is_windows = package.config:sub(1, 1) == '\\'
    local path_separator = is_windows and '\\' or '/'

    for i = 1, #buffers do
        local is_active = vim.api.nvim_buf_is_loaded(buffers[i])
        if is_active then
            local buf_name = vim.api.nvim_buf_get_name(buffers[i])

            -- if buffer name is empty then ignore
            if string.len(buf_name) == 0 then
                goto continue
            end

            -- filter ignore patterns
            if Rt.config.ignore_patterns then
                for j = 1, #Rt.config.ignore_patterns do
                    if string.match(buf_name, Rt.config.ignore_patterns[j]) then
                        goto continue
                    end
                end
            end

            local show_name = buf_name:gsub(string.gsub(cwd .. path_separator, "([%p])", "%%%1"), '')
            show_name = string.gsub(show_name, tostring(Helpers.get_home_dir()), '~')

            if Rt.config.slim_path then
                local short_name = ''
                local parts = {}
                for token in string.gmatch(show_name, "([^" .. path_separator .. "]+)") do
                    if token ~= '~' then
                        table.insert(parts, token:sub(1, 3) .. path_separator)
                    end
                end

                table.remove(parts)

                for _, part in ipairs(parts) do
                    short_name = short_name .. part
                end

                if show_name:sub(1, 1) == '~' then
                    short_name = '~' .. path_separator .. short_name
                end

                local file_name = buf_name:match("([^/\\]+)$")
                show_name = short_name .. file_name
            end

            if show_name:len() > max_len then
                max_len = show_name:len() + 5
            end

            table.insert(Rt.buffer_list, {
                buffers[i],
                show_name,
            })
        end
        ::continue::
    end

    Rt.win_len = max_len
    local max_width = vim.api.nvim_get_option_value('columns', { scope = 'global' })

    if not Rt.config.window.auto_width then
        if Rt.config.window.fixed_width then
            Rt.win_len = Rt.config.window.fixed_width
        end

        if Rt.config.window.percentage_width then
            Rt.win_len = math.floor(max_width * Rt.config.window.percentage_width)
        end
    end

    Rt.buf = vim.api.nvim_create_buf(false, true)
    local win_opts = {
        split = 'left',
        win = current_win,
        width = Rt.win_len,
    }
    Rt.win = vim.api.nvim_open_win(Rt.buf, true, win_opts)
    Rt.previous_win = current_win

    Buffer.initialize(Rt)
end

---@param user_config UserConfig
function Buff.setup(user_config)
    Rt.config = Config.get_config(user_config or {})
end

vim.api.nvim_create_user_command("BuffListToggle", Buff.toggle_buffer_list, {})

return Buff
