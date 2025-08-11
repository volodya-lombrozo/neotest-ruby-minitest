# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'loog'
require 'threads'
require_relative '../lib/factbase'
require_relative '../lib/factbase/inv'
require_relative '../lib/factbase/logged'
require_relative '../lib/factbase/pre'
require_relative '../lib/factbase/rules'
require_relative 'test__helper'

# Factbase main module test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2025 Yegor Bugayenko
# License:: MIT
class TestFactbase < Factbase::Test
  def test_injects_data_correctly
    maps = []
    fb = Factbase.new(maps)
    fb.insert
    f = fb.insert
    f.foo = 1
    f.bar = 2
    f.bar = 3
    assert_equal(2, maps.size)
    assert_equal(0, maps[0].size)
    assert_equal(2, maps[1].size)
    assert_equal([1], maps[1]['foo'])
    assert_equal([2, 3], maps[1]['bar'])
  end

  def test_query_many_times
    fb = Factbase.new
    total = 5
    total.times { fb.insert }
    total.times do
      assert_equal(5, fb.query('(always)').each.to_a.size)
    end
  end

  def test_converts_query_to_term
    fb = Factbase.new
    term = fb.to_term('(eq foo 42)')
    assert_equal('(eq foo 42)', term.to_s)
  end

  def test_simple_setting
    fb = Factbase.new
    fb.insert
    fb.insert.bar = 88
    found = 0
    fb.query('(exists bar)').each do |f|
      assert_predicate(f.bar, :positive?)
      f.foo = 42
      assert_equal(42, f.foo)
      found += 1
    end
    assert_equal(1, found)
    assert_equal(2, fb.size)
  end
end

