local results = require("neotest-ruby-minitest.results")
local path = require("plenary.path")
local async = require("nio.tests")

local OUT_STUB = { output = "/dev/null/raw.txt" }

-- Helper to create and clean up a temporary directory
-- for testing.
local function with_temp_dir(run)
    local base = vim.uv.os_tmpdir()
    local dir = vim.uv.fs_mkdtemp(base .. "/neotest-ruby-minitest-XXXXXX")
    local ok, err = pcall(run, dir)
    if dir then
        path:new(dir):rm({ recursive = true })
    end
    assert(ok, err)
end

-- Get a resource path relative to this file.
--@return plenary.Path
local function resource(...)
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    local spec = path:new(src):parent()
    for _, p in ipairs({ ... }) do
        spec = spec:joinpath(p)
    end
    return spec
end

-- Copy a file from one path to another, overwriting if necessary.
-- Raises an error if the copy fails.
local function copy(from, to)
    local ok, err = pcall(function()
        from:copy({ destination = to, overwrite = true })
    end)
    assert(ok, err)
end

local function params(json_path)
    return { context = { json_path = json_path } }, OUT_STUB, nil
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
            local res = results.parse(params(json_path))
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
            local res = results.parse(params(json_path))
            assert.are_same({}, res)
        end)
    end)

    async.it("parses valid json output", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local from = resource("json", "test_out.json")
            local to = path:new(json_path)
            copy(from, to)
            local res = results.parse(params(json_path))
            assert.are_equal(63, vim.tbl_count(res))
        end)
    end)

    async.it("parses successful json output", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local from = resource("json", "successful.json")
            local to = path:new(json_path)
            copy(from, to)
            local res = results.parse(params(json_path))
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
            copy(from, to)
            local res = results.parse(params(json_path))
            assert.are_equal(1, vim.tbl_count(res))
            local _, test = next(res)
            assert.no_nil(test)
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

    async.it("parses skipped json output", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local from = resource("json", "skipped.json")
            local to = path:new(json_path)
            copy(from, to)
            local res = results.parse(params(json_path))
            assert.are_equal(1, vim.tbl_count(res))
            local _, test = next(res)
            assert.no_nil(test)
            assert.are_equal("skipped", test.status)
            assert.no_nil(test.short:find("Skipped: Does not work", 1, true))
            assert.are_equal(nil, test.localtion)
            assert.are_equal(0.000022000051103532314, test.duration)
        end)
    end)

    async.it("removes the output file on parse by default", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local from = resource("json", "successful.json")
            local to = path:new(json_path)
            copy(from, to)
            results.parse(params(json_path))
            assert.is_false(path:new(json_path):exists())
        end)
    end)

    async.it("keeps the output file on parse", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local from = resource("json", "successful.json")
            local to = path:new(json_path)
            copy(from, to)
            local module = require("neotest-ruby-minitest.results")
            module.keep_output = true
            module.parse(params(json_path))
            assert.is_true(path:new(json_path):exists())
        end)
    end)

    async.it("sets the correct id", function()
        with_temp_dir(function(dir)
            local json_path = dir .. "/results.json"
            local from = resource("json", "successful.json")
            local to = path:new(json_path)
            copy(from, to)
            local res = results.parse(params(json_path))
            assert.are_equal(1, vim.tbl_count(res))
            local id, _ = next(res)
            assert.are_equal("/test/factbase/terms/test_ordering.rb::TestOrdering::test_prev", id)
        end)
    end)
end)
