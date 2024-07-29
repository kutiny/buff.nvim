local Helpers = {}

---Gets the home directory for current user
---@return string?
function Helpers.get_home_dir()
    local home = os.getenv("HOME")
    if not home then
        home = os.getenv("USERPROFILE")
    end
    return home
end

return Helpers
