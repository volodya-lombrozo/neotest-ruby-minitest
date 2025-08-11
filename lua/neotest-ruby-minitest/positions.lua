local lib = require("neotest.lib")


local M = {}

local QUERY = [[
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

M.discover_positions = function(file_path)
    if not vim.loop.fs_stat(file_path) then
        error("File does not exist: " .. file_path)
    end
    local res = lib.treesitter.parse_positions(file_path, QUERY, {
        nested_tests = true,
        require_namespaces = true,
        position_id = nil,
    })
    return res
end

return M
