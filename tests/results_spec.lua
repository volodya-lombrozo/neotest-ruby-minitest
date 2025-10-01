local results = require("neotest-ruby-minitest.results")
local path = require("plenary.path")
local async = require("nio.tests")
local utils = require("tests.commons")

local OUT_STUB = { output = "/dev/null/raw.txt" }

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
    utils.with_temp_dir(function(dir)
      local json_path = dir .. "/results.json"
      local res = results.parse(params(json_path))
      assert.are_same({}, res)
    end)
  end)

  async.it("can't parse ivalid json", function()
    utils.with_temp_dir(function(dir)
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
    utils.with_temp_dir(function(dir)
      local json_path = dir .. "/results.json"
      local from = utils.resource("json", "test_out.json")
      local to = path:new(json_path)
      utils.copy(from, to)
      local res = results.parse(params(json_path))
      assert.are_equal(63, vim.tbl_count(res))
    end)
  end)

  async.it("parses successful json output", function()
    utils.with_temp_dir(function(dir)
      local json_path = dir .. "/results.json"
      local from = utils.resource("json", "successful.json")
      local to = path:new(json_path)
      utils.copy(from, to)
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
    utils.with_temp_dir(function(dir)
      local json_path = dir .. "/results.json"
      local from = utils.resource("json", "failure.json")
      local to = path:new(json_path)
      utils.copy(from, to)
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
    utils.with_temp_dir(function(dir)
      local json_path = dir .. "/results.json"
      local from = utils.resource("json", "skipped.json")
      local to = path:new(json_path)
      utils.copy(from, to)
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
    utils.with_temp_dir(function(dir)
      local json_path = dir .. "/results.json"
      local from = utils.resource("json", "successful.json")
      local to = path:new(json_path)
      utils.copy(from, to)
      results.parse(params(json_path))
      assert.is_false(path:new(json_path):exists())
    end)
  end)

  async.it("keeps the output file on parse", function()
    utils.with_temp_dir(function(dir)
      local json_path = dir .. "/results.json"
      local from = utils.resource("json", "successful.json")
      local to = path:new(json_path)
      utils.copy(from, to)
      local module = require("neotest-ruby-minitest.results")
      module.keep_output = true
      module.parse(params(json_path))
      assert.is_true(path:new(json_path):exists())
    end)
  end)

  async.it("sets the correct id", function()
    utils.with_temp_dir(function(dir)
      local json_path = dir .. "/results.json"
      local from = utils.resource("json", "successful.json")
      local to = path:new(json_path)
      utils.copy(from, to)
      local res = results.parse(params(json_path))
      assert.are_equal(1, vim.tbl_count(res))
      local id, _ = next(res)
      assert.are_equal("/test/factbase/terms/test_ordering.rb::TestOrdering::test_prev", id)
    end)
  end)
end)
