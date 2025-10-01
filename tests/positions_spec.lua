local positions = require("neotest-ruby-minitest.positions")
local async = require("nio.tests")
local utils = require("tests.commons")

describe("positions.discover_positions", function()
  local function find(all, type)
    for _, child in all:iter_nodes() do
      if child:data().type == type then
        return child:data()
      end
    end
    error("No " .. type .. " found")
  end

  -- Helper function to find the first namespace position
  ---@param all neotest.Tree
  ---@return any
  local function namespace(all)
    return find(all, "namespace")
  end

  -- Helper function to find the first test position
  ---@param all neotest.Tree
  ---@return any
  local function test(all)
    return find(all, "test")
  end

  -- Helper function to find the first file position
  ---@param all neotest.Tree
  ---@return any
  local function file(all)
    return find(all, "file")
  end

  -- Helper function to get the absolute path of a minitest example file
  ---@param name string
  ---@return string
  local function minitest(name)
    return utils.resource("examples", "superclasses", name):absolute()
  end

  async.it("discovers all tests in a plain ruby test", function()
    local pos = positions.discover_positions(minitest("plain_test.rb"))
    assert.are.same("plain_test.rb", file(pos).name)
    assert.are.same("UserTest", namespace(pos).name)
    assert.are.same("test_truth", test(pos).name)
  end)

  async.it("discovers all tests in a bare minitest example", function()
    local pos = positions.discover_positions(minitest("bare_test.rb"))
    assert.are.same("bare_test.rb", file(pos).name)
    assert.are.same("Bare", namespace(pos).name)
    assert.are.same("test_custom", test(pos).name)
  end)

  async.it("discovers all tests in a minitest example that uses a custom base class in other module", function()
    local pos = positions.discover_positions(minitest("custom_base_test.rb"))
    assert.are.same("custom_base_test.rb", file(pos).name)
    assert.are.same("ApiTest", namespace(pos).name)
    assert.are.same("test_ping", test(pos).name)
  end)

  async.it("discovers all tests in a minitest example that uses ActionDispatch:IntegrationTest", function()
    local pos = positions.discover_positions(minitest("inside_module_test.rb"))
    assert.are.same("inside_module_test.rb", file(pos).name)
    assert.are.same("UsersController", namespace(pos).name)
    assert.are.same("test_index", test(pos).name)
  end)

  async.it("discovers all tests in a minitest example that uses legacy MiniTest::Unit::TestCase", function()
    local pos = positions.discover_positions(minitest("legacy_test.rb"))
    assert.are.same("legacy_test.rb", file(pos).name)
    assert.are.same("LegacyExampleTest", namespace(pos).name)
    assert.are.same("test_legacy", test(pos).name)
  end)

  async.it("discovers all tests in a rails minitest example", function()
    local pos = positions.discover_positions(minitest("rails_test.rb"))
    assert.are.same("rails_test.rb", file(pos).name)
    assert.are.same("UserModelTest", namespace(pos).name)
    assert.are.same("test_valid", test(pos).name)
  end)

  async.it("discovers all tests in a rails integration test example", function()
    local pos = positions.discover_positions(minitest("rails_intergration_test.rb"))
    assert.are.same("rails_intergration_test.rb", file(pos).name)
    assert.are.same("UsersControllerTest", namespace(pos).name)
    assert.are.same("test_index", test(pos).name)
  end)

  async.it("discovers all tests in a rails job test example", function()
    local pos = positions.discover_positions(minitest("rails_job_test.rb"))
    assert.are.same("rails_job_test.rb", file(pos).name)
    assert.are.same("UserJobTest", namespace(pos).name)
    assert.are.same("test_enqueue", test(pos).name)
  end)

  async.it("discovers all tests in a rails integration rails mailer test", function()
    local pos = positions.discover_positions(minitest("rails_mailer_test.rb"))
    assert.are.same("rails_mailer_test.rb", file(pos).name)
    assert.are.same("AccountMailerTest", namespace(pos).name)
    assert.are.same("test_welcome_email", test(pos).name)
  end)

  async.it("discovers all tests in a rails integration rails mailer test", function()
    local pos = positions.discover_positions(minitest("test_rails_system.rb"))
    assert.are.same("test_rails_system.rb", file(pos).name)
    assert.are.same("LoginFlowTest", namespace(pos).name)
    assert.are.same("test_homepage", test(pos).name)
  end)
end)

describe("Discover Positions", function()
  local is_win = package.config:sub(1, 1) == '\\'
  local function norm(p) return vim.fs.normalize(p) end
  local function base(p) return vim.fs.basename(p) end
  -- This is a workaround to ensure the tests work correctly on both Windows and Unix-like systems.
  -- On Windows, neotest.lib.treesitter.parse_positions returns full file paths,
  -- whereas on Unix-like systems, it returns only the filename.
  local function file_name(path)
    return is_win and norm(path) or base(path)
  end

  async.it("should discover the position of the classic minitest from the 'factbase' project", function()
    local test_path = utils.resource("examples", "test_factbase.rb"):absolute()
    local actual = positions.discover_positions(test_path):to_list()
    local expected = {
      {
        id = test_path,
        name = file_name(test_path),
        path = test_path,
        range = { 0, 0, 65, 0 },
        type = "file",
      },
      {
        {
          id = test_path .. "::TestFactbase",
          name = "TestFactbase",
          path = test_path,
          range = { 18, 0, 63, 3 },
          type = "namespace",
        },
        {
          {
            id = test_path .. "::TestFactbase::test_injects_data_correctly",
            name = "test_injects_data_correctly",
            path = test_path,
            range = { 19, 2, 32, 5 },
            type = "test",
          },
        },

        {
          {
            id = test_path .. "::TestFactbase::test_query_many_times",
            name = "test_query_many_times",
            path = test_path,
            range = { 34, 2, 41, 5 },
            type = "test",
          },
        },
        {
          {
            id = test_path .. "::TestFactbase::test_converts_query_to_term",
            name = "test_converts_query_to_term",
            path = test_path,
            range = { 43, 2, 47, 5 },
            type = "test",
          },
        },
        {
          {
            id = test_path .. "::TestFactbase::test_simple_setting",
            name = "test_simple_setting",
            path = test_path,
            range = { 49, 2, 62, 5 },
            type = "test",
          },
        },
      },
    }
    assert.are.same(expected, actual)
  end)

  async.it("should discover correct positions in the classic example", function()
    local test_path = utils.resource("examples", "test_classic.rb"):absolute()
    local actual = positions.discover_positions(test_path):to_list()
    local expected = {
      {
        id = test_path,
        name = file_name(test_path),
        path = test_path,
        range = { 0, 0, 10, 0 },
        type = "file",
      },
      {
        {
          id = test_path .. "::Classic",
          name = "Classic",
          path = test_path,
          range = { 4, 0, 8, 3 },
          type = "namespace",
        },
        {
          {
            id = test_path .. "::Classic::test_add",
            name = "test_add",
            path = test_path,
            range = { 5, 2, 7, 5 },
            type = "test",
          },
        },
      },
    }
    assert.are.same(expected, actual)
  end)
end)

describe("Environment sanity", function()
  it("has the Tree-sitter Ruby parser installed", function()
    local parsers = require("nvim-treesitter.parsers")
    assert.is_true(
      parsers.has_parser("ruby"),
      "Tree-sitter Ruby parser is not installed. Run :TSInstall ruby in Neovim."
    )
  end)
end)
