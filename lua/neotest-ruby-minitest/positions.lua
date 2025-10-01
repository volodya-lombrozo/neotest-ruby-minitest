local lib = require("neotest.lib")

local M = {}

local plain_query = [[
    (
      class
      name: (constant) @namespace.name
      (superclass (scope_resolution) @superclass (#match? @superclass "Test$"))
    ) @namespace.definition
    (
      method
      name: (identifier) @test.name (#match? @test.name "^test_")
    ) @test.definition
]]

-- Parses the given file with the plain query.
---@param file string
---@return neotest.Tree
local function plain(file)
  return lib.treesitter.parse_positions(file, plain_query, {
    nested_tests = true,
    require_namespaces = true,
    position_id = nil,
  })
end


local bare_query = [[
    (
     class
     name: (constant) @namespace.name
     (superclass
      [
        (scope_resolution) @superclass.fq
        (constant)         @superclass.name
      ]
     )
  ) @namespace.definition

  (
    method
    name: (identifier) @test.name (#match? @test.name "^test_")
  ) @test.definition
]]

-- Parses the given file with the bare query.
---@param file string
---@return neotest.Tree
local function bare(file)
  return lib.treesitter.parse_positions(file, bare_query, {
    nested_tests = true,
    require_namespaces = true,
    position_id = nil,
  })
end

---@param tree neotest.Tree
---@return integer
local function count_nodes(tree)
  ---@param node neotest.Tree
  ---@return integer
  local function recurse(node)
    local n = 1
    if not node then
      return n
    end
    for _, child in ipairs(node:children()) do
      n = n + recurse(child)
    end
    return n
  end
  return recurse(tree)
end

-- Parses the given file and returns a tree of positions.
---@param file_path string
---@return neotest.Tree
M.discover_positions = function(file_path)
  if not vim.loop.fs_stat(file_path) then
    error("file does not exist: " .. file_path)
  end
  local b = bare(file_path)
  local p = plain(file_path)
  if count_nodes(b) > count_nodes(p) then
    return b
  else
    return p
  end
end

return M
