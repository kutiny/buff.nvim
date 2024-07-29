local Config = {}

---@alias CallbackFn fun()
---@alias UserConfig{ignore_patterns: string[]?}
---@alias BuffConfig{ignore_patterns: string[]?}

---Joins the user configuration with defaults
---@param user_config UserConfig
---@return BuffConfig
function Config.get_config(user_config)
    local default_config = {
        ignore_patterns = {},
    }

    return vim.tbl_extend('keep', user_config or {}, default_config)
end

return Config