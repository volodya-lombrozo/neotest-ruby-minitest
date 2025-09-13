local positions = require("neotest-ruby-minitest.positions")
local async = require("nio.tests")

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
        local test_path = vim.fs.joinpath(vim.loop.cwd(), "tests", "examples", "test_factbase.rb")
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
        local test_path = vim.fs.joinpath(vim.loop.cwd(), "tests", "examples", "test_classic.rb")
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
