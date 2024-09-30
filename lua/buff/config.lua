local Config = {}

---@alias CallbackFn fun()
---@alias UserConfig{ignore_patterns: string[]?, slim_path: boolean, window: { fixed_width?: number, percentage_width?: number, auto_width: boolean }}
---@alias BuffConfig{ignore_patterns: string[]?, slim_path: boolean, window: { fixed_width?: number, percentage_width?: number, auto_width: boolean }}

---Joins the user configuration with defaults
---@param user_config UserConfig
---@return BuffConfig
function Config.get_config(user_config)
    local default_config = {
        ignore_patterns = {},
        slim_path = true,
        window = {
            auto_width = true,
        },
    }

    if user_config.window and user_config.window.percentage_width then
        if user_config.window.percentage_width >= 1 then
            user_config.window.percentage_width = user_config.window.percentage_width / 100.0
        end
    end

    return vim.tbl_extend('keep', user_config or {}, default_config)
end

return Config
