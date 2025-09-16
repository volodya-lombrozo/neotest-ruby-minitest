local adapter = require("neotest-ruby-minitest.command")
local positions = require("neotest-ruby-minitest.positions")
local async = require("nio.tests")

describe("Build Ruby Test Command", function()
    local test_file = "./tests/examples/test_classic.rb"
    local find = function(filename, type)
        local tree = positions.discover_positions(filename)
        for _, node in tree:iter_nodes() do
            local data = node:data()
            if data and data.type == type then
                return node
            end
        end
    end

    local function dir_tree(path)
        return {
            data = function()
                return {
                    id = path,
                    name = path,
                    path = path,
                    type = "dir",
                }
            end,
            iter_nodes = function()
                local files = vim.fn.readdir(path)
                local nodes = {}
                for _, file in ipairs(files) do
                    local full_path = path .. "/" .. file
                    if vim.fn.isdirectory(full_path) == 1 then
                        table.insert(nodes, dir_tree(full_path))
                    elseif file:match("%.rb$") then
                        table.insert(nodes, {
                            data = function()
                                return {
                                    id = full_path,
                                    name = file,
                                    type = "file",
                                    path = full_path,
                                }
                            end,
                            iter_nodes = function()
                                return {}
                            end,
                        })
                    end
                end
                local i = 0
                return function()
                    i = i + 1
                    if i > #nodes then return nil end
                    return i, nodes[i]
                end
            end,
        }
    end

    async.it("should build a command for a single test unit", function()
        local unit = find(test_file, "test")
        local actual = adapter.build({ command = "ruby" }, { tree = unit })
        assert.are.same({ "ruby", test_file, "-n", "test_add" }, actual.command)
    end)

    async.it("should build a command for a single test file", function()
        local file = find(test_file, "file")
        local spec = adapter.build({ command = "bundle exec ruby -Ilib:test" }, {
            tree = file,
            extra_args = {},
            strategy = nil
        })
        assert.are.same({ "bundle", "exec", "ruby", "-Ilib:test", test_file }, spec.command)
    end)

    async.it("should build a command for a directory", function()
        local dir = dir_tree("./tests/examples")
        local actual = adapter.build({ command = "bundle" }, { tree = dir })
        assert.are.same({
            "bundle",
            "-e",
            "ARGV.each { |f| require File.expand_path(f) }",
            "--",
            "./tests/examples/test_classic.rb",
            "./tests/examples/test_factbase.rb"
        }, actual.command)
    end)

    async.it("should create a path for json ouput", function()
        local unit = find(test_file, "test")
        local actual = adapter.build({ command = "ruby" }, { tree = unit })
        assert.no_nil(actual)
        local json_path = actual.context.json_path
        assert.is_string(json_path)
        assert.is_match("%.json$", json_path)
    end)
end)

describe("Finds Json Tap Plugin For Ruby Minitest", function()
    async.it("should find the json_tap plugin", function()
        local plugin_rb = adapter.json_tap()
        assert.is_string(plugin_rb)
        assert.is_true(vim.endswith(plugin_rb, "json_tap.rb"))
        assert.is_true(vim.fn.filereadable(plugin_rb) == 1)
    end)
end)

describe("Creates State Directory", function()
    async.it("should create a state directory", function()
        local state_dir = adapter.state_dir()
        assert.is_string(state_dir)
        assert.is_true(vim.fn.isdirectory(state_dir) == 1)
    end)
end)
