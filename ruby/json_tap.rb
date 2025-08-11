# frozen_string_literal: true

require "json"
require "minitest"

# --- universal, reporter-agnostic collector ---
module Minitest
  module JsonTap
    @examples = []
    class << self
      attr_reader :examples
      attr_accessor :io_path, :enabled
    end

    def self.record(result)
      @examples << {
        file: result.source_location&.first,
        line: result.source_location&.last,
        class: result.respond_to?(:klass) ? result.klass : nil,
        name: result.name,
        time: result.time,
        assertions: result.assertions,
        failures: result.failures.map { |f| { type: f.result_label, message: f.message, backtrace: f.backtrace } },
        skipped: result.skipped?,
        error: result.error?
      }
    end

    def self.dump!
      return unless enabled
      out =
        if io_path && !io_path.empty?
          File.open(io_path, "w")
        else
          $stdout
        end
      payload = {
        summary: {
          total: examples.length,
          assertions: examples.sum { |e| e[:assertions] || 0 },
          failures: examples.count { |e| !e[:failures].empty? },
          errors:   examples.count { |e| e[:error] },
          skips:    examples.count { |e| e[:skipped] },
          duration: examples.sum { |e| e[:time] || 0.0 }
        },
        tests: examples
      }
      out.puts JSON.generate(payload)
      out.flush
    end
  end
end

# Prepend into reporters so every result passes through our tap.
module Minitest
  module JsonTapRecord
    def record(result)
      Minitest::JsonTap.record(result)
      super
    end
  end

  module JsonTapReport
    def report
      super
      Minitest::JsonTap.dump! if Minitest::JsonTap.enabled
    end
  end
end

begin
  Minitest::Reporter.prepend(Minitest::JsonTapRecord)          if defined?(Minitest::Reporter)
  Minitest::Reporter.prepend(Minitest::JsonTapReport)          if defined?(Minitest::Reporter)
  Minitest::CompositeReporter.prepend(Minitest::JsonTapRecord) if defined?(Minitest::CompositeReporter)
  Minitest::CompositeReporter.prepend(Minitest::JsonTapReport) if defined?(Minitest::CompositeReporter)
rescue NameError
  # ignore
end

# Enable from env (no reliance on plugin init order)
if ENV["MINITEST_JSON"] == "1" || (ENV["MINITEST_JSON_FILE"] && !ENV["MINITEST_JSON_FILE"].empty?)
  Minitest::JsonTap.enabled = true
  Minitest::JsonTap.io_path = ENV["MINITEST_JSON_FILE"]
end

# Still keep after_run as fallback in case autorun is used.
Minitest.after_run { Minitest::JsonTap.dump! if Minitest::JsonTap.enabled }

