local results = require("neotest-ruby-minitest.results")
local path = require("plenary.path")
local async = require("nio.tests")

local with_temp_dir = function(run)
    local base = vim.uv.os_tmpdir()
    local dir = vim.uv.fs_mkdtemp(base .. "/neotest-ruby-minitest-XXXXXX")
    local ok, err = pcall(run, dir)
    if dir then
        path:new(dir):rm({ recursive = true })
    end
    assert(ok, err)
end

-- Get the directory of this spec file
--@return plenary.Path
local function resource()
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    return path:new(src):parent()
end

describe("results.parse", function()
    async.it("can't find a file", function()
        local spec = { context = { json_path = "/dev/null/missing.json" } }
        local result = { output = "/dev/null/raw.txt" }
        assert.are_same({}, results.parse(spec, result, nil))
    end)

    async.it("can't parse empty json", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local res = results.parse({ context = { json_path = json_path } }, { output = "/dev/null/raw.txt" }, nil)
            assert.are_same({}, res)
        end)
    end)

    async.it("can't parse ivalid json", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local content = "{ invalid json }"
            local file = io.open(json_path, "w")
            assert(file, "could not open file for writing: " .. json_path)
            file:write(content)
            file:close()
            local res = results.parse({ context = { json_path = json_path } }, { output = "/dev/null/raw.txt" }, nil)
            assert.are_same({}, res)
        end)
    end)

    async.it("parses valid json output", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local from = resource():joinpath("json"):joinpath("test_out.json")
            local to = path:new(json_path)
            local ok, err = pcall(function()
                from:copy({ destination = to, overwrite = true })
            end)
            assert(ok, err)
            local res = results.parse({ context = { json_path = json_path } }, { output = "/dev/null/raw.txt" }, nil)
            assert.are_equal(63, vim.tbl_count(res))
        end)
    end)

    async.it("parses successful json output", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local from = resource():joinpath("json"):joinpath("successful.json")
            local to = path:new(json_path)
            local ok, err = pcall(function()
                from:copy({ destination = to, overwrite = true })
            end)
            assert(ok, err)
            local res = results.parse({ context = { json_path = json_path } }, { output = "/dev/null/raw.txt" }, nil)
            assert.are_equal(1, vim.tbl_count(res))
            local _, single = next(res)
            assert.are_equal("passed", single.status)
            assert.are_equal("", single.short)
            assert.are_equal("/dev/null/raw.txt", single.output)
            assert.are_equal(nil, single.localtion)
            assert.are_equal(0.00010799989104270935, single.duration)
            assert.are_same({}, single.errors)
        end)
    end)

    async.it("parses failed json output", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local from = resource():joinpath("json"):joinpath("failure.json")
            local to = path:new(json_path)
            local ok, err = pcall(function()
                from:copy({ destination = to, overwrite = true })
            end)
            assert(ok, err)
            local res = results.parse({ context = { json_path = json_path } }, { output = "/dev/null/raw.txt" }, nil)
            assert.are_equal(1, vim.tbl_count(res))
            local _, test = next(res)
            assert.are_equal("failed", test.status)
            assert.no_nil(test.short:find("Failure: [ foo: [42, 256] ].", 1, true))
            assert.no_nil(test.short:find("Expected: [43, 256]", 1, true))
            assert.no_nil(test.short:find("Actual: [42, 256]", 1, true))
            assert.are_equal("/dev/null/raw.txt", test.output)
            assert.are_equal(nil, test.localtion)
            assert.are_equal(0.00019100005738437175751, test.duration)
            assert.no_nil(test.errors[1])
        end)
    end)


    async.it("removes the output file on parse", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local from = resource():joinpath("json"):joinpath("successful.json")
            local to = path:new(json_path)
            local ok, err = pcall(function()
                from:copy({ destination = to, overwrite = true })
            end)
            assert(ok, err)
            results.parse({ context = { json_path = json_path } }, { output = "/dev/null" }, nil)
            assert.is_false(path:new(json_path):exists())
        end)
    end)
end)
