local M = {}

local function get_home_dir()
    local home = os.getenv("HOME")
    if not home then
        home = os.getenv("USERPROFILE")
    end
    return home
end

function M.show_buffer_list()
    local buffers = vim.api.nvim_list_bufs()

    local text = {}
    for i = 1, #buffers do
        local is_active = vim.api.nvim_buf_is_loaded(buffers[i])
        if is_active then
            local buf_name = vim.api.nvim_buf_get_name(buffers[i])
            local home_dir = get_home_dir()
            local buf_text = string.gsub(buf_name, home_dir, '~')
            table.insert(text, buf_text)
        end
    end

    local buf = vim.api.nvim_create_buf(false, true)
    local win_opts = {
        relative = 'editor',
        width = 80,
        height = 10,
        row = 1,
        col = 0,
        style = 'minimal',
        border = 'single',
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
end

return M
