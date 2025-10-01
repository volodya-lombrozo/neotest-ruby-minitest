local path = require("plenary.path")

local M = {}

-- get a resource path relative to this file.
--@return plenary.path
M.resource = function(...)
  local src = debug.getinfo(1, "S").source
  if src:sub(1, 1) == "@" then src = src:sub(2) end
  local spec = path:new(src):parent()
  for _, p in ipairs({ ... }) do
    spec = spec:joinpath(p)
  end
  return spec
end

-- Helper to create and clean up a temporary directory
-- for testing.
M.with_temp_dir = function(run)
  local base = vim.uv.os_tmpdir()
  local dir = vim.uv.fs_mkdtemp(base .. "/neotest-ruby-minitest-XXXXXX")
  local ok, err = pcall(run, dir)
  if dir then
    path:new(dir):rm({ recursive = true })
  end
  assert(ok, err)
end

-- Copy a file from one path to another, overwriting if necessary.
-- Raises an error if the copy fails.
M.copy = function(from, to)
  local ok, err = pcall(function()
    from:copy({ destination = to, overwrite = true })
  end)
  assert(ok, err)
end

return M
