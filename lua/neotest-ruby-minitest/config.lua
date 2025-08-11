local M = {}

---@class config.Config
---@field command "string" Command to run the tests. Should be a string.

M.defaults = {
    command = "bundle exec ruby -Itest",
}

function M.resolve(opts)
    return vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
