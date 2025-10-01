local adapter = require("neotest-ruby-minitest.init")

describe("adapter.filter_dir", function()
  local test_cases = {
    { name = "vendor",       rel_path = "some_dir/vendor",       root = "/", expected = false },
    { name = ".git",         rel_path = "some_dir/.git",         root = "/", expected = false },
    { name = "node_modules", rel_path = "some_dir/node_modules", root = "/", expected = false },
    { name = "tmp",          rel_path = "some_dir/tmp",          root = "/", expected = false },
    { name = "app",          rel_path = "some_dir/app",          root = "/", expected = true },
    { name = "lib",          rel_path = "some_dir/lib",          root = "/", expected = true },
    { name = "test",         rel_path = "some_dir/test",         root = "/", expected = true }
  }
  for _, test_case in ipairs(test_cases) do
    it("returns " .. tostring(test_case.expected) .. " for directory " .. test_case.name, function()
      local result = adapter.filter_dir(test_case.name, test_case.rel_path, test_case.root)
      assert.are_equal(test_case.expected, result)
    end)
  end
end)

describe('adapter.is_test_file', function()
  it('is_test_file', function()
    assert.is_true(adapter.is_test_file("foo_test.rb"))
    assert.is_true(adapter.is_test_file("test_foo.rb"))
    assert.is_false(adapter.is_test_file("foo.rb"))
    assert.is_true(adapter.is_test_file("nested/test_bar.rb"))
    assert.is_true(adapter.is_test_file("nested/foo_test.rb"))
  end)
end)
