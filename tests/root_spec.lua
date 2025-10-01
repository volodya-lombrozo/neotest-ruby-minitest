local rm = require("neotest-ruby-minitest.root")
local lib = require("neotest.lib")
local fs = require("vim.fs")

describe("root function", function()
  local mock_files = {}
  before_each(function()
    mock_files = {}
    lib.files.exists = function(path)
      return mock_files[path] or false
    end

    lib.files.match_root_pattern = function(...)
      local patterns = { ... }
      return function(dir)
        while dir do
          for _, pattern in ipairs(patterns) do
            if mock_files[fs.joinpath(dir, pattern)] then
              return dir
            end
          end
          local parent = fs.dirname(dir)
          if parent == dir then break end
          dir = parent
        end
        return nil
      end
    end
  end)

  it("returns the nearest Bundler/Ruby project root", function()
    mock_files["/project/Gemfile"] = true
    mock_files["/project/test/test_helper.rb"] = true
    local result = rm.root("/project/app/models")
    assert.are.equal("/project", result)
  end)

  it("falls back to stricter Minitest layout if no Bundler/Ruby markers", function()
    mock_files["/project/test/test_helper.rb"] = true
    local result = rm.root("/project/app/models")
    assert.are.equal("/project", result)
  end)

  it("walks up the directory tree to find Minitest layout", function()
    mock_files["/project/test/test_helper.rb"] = true
    local result = rm.root("/project/app/models")
    assert.are.equal("/project", result)
  end)

  it("respects VCS root as the last fallback", function()
    mock_files["/repo/.git"] = true
    local result = rm.root("/repo/app/models")
    assert.are.equal("/repo", result)
  end)

  it("returns nil for non-project contexts", function()
    local result = rm.root("/random/path")
    assert.are.equal(nil, result)
  end)

  it("handles nested apps/engines in a monorepo", function()
    mock_files["/monorepo/engine/test/test_helper.rb"] = true
    local result = rm.root("/monorepo/engine/app/models")
    assert.are.equal("/monorepo/engine", result)
  end)

  it("prioritizes nearer Gemfile over VCS root", function()
    mock_files["/repo/.git"] = true
    mock_files["/repo/project/Gemfile"] = true
    local result = rm.root("/repo/project/app/models")
    assert.are.equal("/repo/project", result)
  end)
end)
