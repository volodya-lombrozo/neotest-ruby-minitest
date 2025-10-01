local M = {}

-- Check if a given file path is a Ruby Minitest test file.
-- A test file typically ends with `_test.rb` or starts with `test_` and ends with `.rb`.
M.is_test_file = function(path)
  if not path then return false end
  if type(path) ~= "string" then return false end
  if not path:match("%.rb$") then return false end
  local fname = vim.fs.basename(path)
  local test = fname:match(".+_test%.rb$") ~= nil or fname:match("test_.+%.rb$") ~= nil
  local spec = fname:match(".+_spec%.rb$") ~= nil or fname:match("spec_.+%.rb$") ~= nil
  local check = fname:match(".+_check%.rb$") ~= nil or fname:match("check_.+%.rb$") ~= nil
  return test or spec or check
end

--- Generate a random RFC-4122-like UUID v4 string.
--- Note: this is not cryptographically secure; it’s sufficient for temp file names.
---@return string uuid
function M.uuid()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  local id = string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
  return id
end

return M
