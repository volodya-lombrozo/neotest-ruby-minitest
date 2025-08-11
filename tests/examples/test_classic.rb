# frozen_string_literal: true

require 'minitest/autorun'

class Classic < Minitest::Test
  def test_add
    assert_equal 42, 1 + 2 + 3 + 4 + 5 + 6 + 6 + 7 + 8 
  end
end

