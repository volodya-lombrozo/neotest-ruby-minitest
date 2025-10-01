local lib = require("neotest.lib")
local fs = require("vim.fs")

local M = {}

local function has_minitest_layout(path)
  return lib.files.exists(fs.joinpath(path, "test"))
      and lib.files.exists(fs.joinpath(path, "test", "test_helper.rb"))
end

function M.root(dir)
  local ruby_root = lib.files.match_root_pattern(
    "Gemfile",
    "gems.rb",
    ".ruby-version",
    ".tool-versions",
    "Rakefile",
    "test/test_helper.rb",
    ".git"
  )(dir)
  if ruby_root then
    return ruby_root
  end
  local current = dir
  while current do
    if has_minitest_layout(current) then
      return current
    end
    local parent = fs.dirname(current)
    if not parent or parent == current then break end
    current = parent
  end
  return nil
end

return M
