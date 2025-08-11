M = {}

M.is_test_file = function(path)
    if not path then return false end
    if type(path) ~= "string" then return false end
    if not path:match("%.rb$") then return false end
    return path:match("_test%.rb$") ~= nil or path:match("test_.+%.rb$") ~= nil
end

return M
