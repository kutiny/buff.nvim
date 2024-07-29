local group = require('buff.autocmd')
local Buffer = {}

---@param rt RuntimeGlobals
function Buffer.initialize(rt)
    vim.api.nvim_create_autocmd('BufLeave', {
        group = group,
        buffer = rt.buf,
        callback = function()
            vim.api.nvim_win_close(rt.win, true)
        end,
    })

    vim.keymap.set('n', '<CR>', function()
        local buf_id = nil
        for i = 1, #rt.buffer_list do
            if rt.buffer_list[i][2] == vim.api.nvim_get_current_line() then
                buf_id = rt.buffer_list[i][1]
            end
        end

        if not buf_id then
            print("There was an error trying to match selection with buffer names.")
            return
        end

        vim.api.nvim_win_close(rt.win, true)
        vim.api.nvim_set_current_buf(buf_id)
    end, {
        buffer = rt.buf,
        silent = true,
    })

    local text = {}
    for i = 1, #rt.buffer_list do
        table.insert(text, rt.buffer_list[i][2])
    end

    vim.api.nvim_buf_set_lines(rt.buf, 0, -1, false, text)
end

return Buffer
