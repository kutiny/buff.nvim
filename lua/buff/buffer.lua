local group = require('buff.autocmd')
local Buffer = {}

function Buffer.open_buffer(rt)
    local buf_id = nil
    for i = 1, #rt.buffer_list do
        if rt.buffer_list[i][2] == vim.api.nvim_get_current_line() then
            buf_id = rt.buffer_list[i][1]
        end
    end

    if not buf_id then
        vim.api.nvim_err_writeln("There was an error trying to match selection with buffer names.")
        return
    end

    pcall(vim.api.nvim_set_current_win, rt.previous_win)
    pcall(vim.api.nvim_win_close, rt.win, true)
    pcall(vim.api.nvim_set_current_buf, buf_id)
end

function Buffer.close_buffer(rt)
    local buf_id = nil
    local current_line = vim.api.nvim_get_current_line()

    if string.len(current_line) == 0 then
        return
    end

    for i = 1, #rt.buffer_list do
        if rt.buffer_list[i][2] == current_line then
            buf_id = rt.buffer_list[i][1]
        end
    end

    local has_changes = vim.api.nvim_get_option_value('modified', { buf = buf_id })
    if has_changes then
        vim.api.nvim_err_writeln("Buffer has pending changes, please save before closing.")
        return
    end

    if not buf_id then
        vim.api.nvim_err_writeln("There was an error trying to close buffer.")
        return
    end

    vim.api.nvim_buf_delete(buf_id, { force = false })
    local coords = vim.api.nvim_win_get_cursor(rt.win)
    vim.api.nvim_buf_set_lines(rt.buf, coords[1] - 1, coords[1], false, {})
end

---@param rt RuntimeGlobals
function Buffer.initialize(rt)
    vim.api.nvim_create_autocmd('BufLeave', {
        group = group,
        buffer = rt.buf,
        callback = function()
            pcall(vim.api.nvim_win_close, rt.win, true)
            pcall(vim.api.nvim_set_current_win, rt.previous_win)
        end,
    })

    vim.keymap.set('n', '<CR>', function()
        Buffer.open_buffer(rt)
    end, { buffer = rt.buf, silent = true, })

    vim.keymap.set('n', 'x', function()
        Buffer.close_buffer(rt)
    end, { buffer = rt.buf, silent = true, })

    local text = {}
    for i = 1, #rt.buffer_list do
        table.insert(text, rt.buffer_list[i][2])
    end

    vim.api.nvim_buf_set_lines(rt.buf, 0, -1, false, text)

    local configs = {
        rnu = false,
        nu = false,
        signcolumn = 'no',
        list = false,
        foldcolumn = '0',
        wrap = false,
        spell = false,
    }

    local opts = {
        win = rt.win,
        scope = 'local'
    }

    for k, v in pairs(configs) do
        vim.api.nvim_set_option_value(k, v, opts)
    end
end

return Buffer
