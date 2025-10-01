local lib = require("neotest.lib")
local util = require("neotest-ruby-minitest.util")
local M = {}

---@param conf config.Config
---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
function M.build(conf, args)
  local location = args.tree:data()
  local test_path = location.path
  if not lib.files.exists(test_path) then
    error("neotest-ruby-minitest: file does not exist: " .. test_path)
  end
  if type(conf.command) ~= "string" then
    error("neotest-ruby-minitest: command must be a string or a table")
  end
  local command = {}
  for word in conf.command:gmatch("%S+") do
    table.insert(command, word)
  end
  if args.extra_args then
    vim.list_extend(command, args.extra_args)
  end
  if location.type == "file" then
    table.insert(command, test_path)
  elseif location.type == "test" then
    table.insert(command, test_path)
    if location.name then
      table.insert(command, "-n")
      table.insert(command, location.name)
    else
      error("neotest-ruby-minitest: test node missing name")
    end
  elseif location.type == "dir" then
    table.insert(command, "-e")
    table.insert(command, "ARGV.each { |f| require File.expand_path(f) }")
    table.insert(command, "--")
    for _, node in args.tree:iter_nodes() do
      local data = node:data()
      if data and data.type == "file" then
        local path = data.path
        if util.is_test_file(path) then
          table.insert(command, path)
        end
      end
    end
  else
    error("neotest-ruby-minitest: unsupported node type: " .. tostring(location.type))
  end
  local plugin_rb = M.json_tap()
  local env = vim.tbl_extend("force", {}, args.env or {})
  local prev = env.RUBYOPT or vim.env.RUBYOPT or ""
  local inject = "-r" .. plugin_rb
  env.RUBYOPT = (prev ~= "" and (prev .. " " .. inject)) or inject
  local dir = M.state_dir()
  local file = util.uuid() .. ".json"
  local json_path = dir .. "/" .. file
  env.MINITEST_JSON_FILE = env.MINITEST_JSON_FILE or json_path
  return {
    command = command,
    env = env,
    context = {
      json_path = json_path,
      plugin_rb = plugin_rb,
    }
  }
end

--- Locate the Ruby plugin on `runtimepath`.
---@return string|nil path  -- First hit on rtp, or nil if not found (a warning is emitted).
function M.json_tap()
  local tap = "ruby/json_tap.rb"
  local hits = vim.api.nvim_get_runtime_file(tap, false)
  if hits and #hits > 0 then
    return hits[1]
  else
    vim.notify("neotest-ruby-minitest: " .. tap .. " not found on runtimepath", vim.log.levels.WARN)
  end
  return nil
end

--- Ensure and return the adapter state directory under Neovim's state path.
--- Example: `<stdpath('state')>/neotest/neotest-ruby-minitest`
---@return string dir
function M.state_dir()
  local dir = vim.fs.joinpath(vim.fn.stdpath("state"), "neotest", "neotest-ruby-minitest")
  if not lib.files.exists(dir) then
    vim.fn.mkdir(dir, "p")
  end
  return dir
end

return M
