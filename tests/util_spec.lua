local util = require("neotest-ruby-minitest.util")
local async = require("nio.tests")

describe("uuid", function()
    async.it("should generate a UUID", function()
        local first = util.uuid()
        local second = util.uuid()
        assert.is_string(first)
        assert.is_string(second)
        assert.not_same(first, second)
        assert.is_true(#first == 36)
        assert.is_true(#second == 36)
    end)
end)

describe('is_test_file', function()
    local test_cases = {
        { input = nil, expected = false },
        { input = 123, expected = false },
        { input = {}, expected = false },
        { input = "example.rb", expected = false },
        { input = "example_test.rb", expected = true },
        { input = "test_example.rb", expected = true },
        { input = "example.test.rb", expected = false },
        { input = "nested/path/example_test.rb", expected = true },
        { input = "test_nested/path/example.rb", expected = false },
        { input = "nested/path/test_example.rb", expected = true },
    }
    for _, case in ipairs(test_cases) do
        it(('returns %s for input "%s"'):format(case.expected, case.input), function()
            assert.are.same(case.expected, util.is_test_file(case.input))
        end)
    end
end)
