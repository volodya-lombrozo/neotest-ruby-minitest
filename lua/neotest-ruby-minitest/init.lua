local conf = require("neotest-ruby-minitest.config")
local logger = require("neotest.logging")

local function build_adapter(cfg)
    local adapter = {}
    logger.info("Building minitest adapter with config: " .. vim.inspect(cfg))

    adapter.name = "neotest-ruby-minitest"

    ---Find the project root directory given a current directory to work from.
    ---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
    ---@async
    ---@param dir string @Directory to treat as cwd
    ---@return string | nil @Absolute root dir of test suite
    function adapter.root(dir)
        logger.info("neotest-ruby-minitest.root " .. tostring(dir))
        return require("neotest-ruby-minitest.root").root(dir)
    end

    ---@async

    ---@param file_path string
    ---@return boolean
    function adapter.is_test_file(path)
        logger.info("neotest-ruby-minitest.is_test_file " .. tostring(path))
        return require("neotest-ruby-minitest.util").is_test_file(path)
    end

    ---Filter directories when searching for test files
    ---@async
    ---@param name string Name of directory
    ---@param rel_path string Path to directory, relative to root
    ---@param root string Root directory of project
    ---@return boolean
    function adapter.filter_dir(name, rel_path, root)
        logger.info(("neotest-ruby-minitest.filter_dir name=%s rel=%s root=%s"):format(name, rel_path, root))
        return not (name == "vendor" or name == ".git" or name == "node_modules" or name == "tmp")
    end

    ---Given a file path, parse all the tests within it.
    ---@async
    ---@param file_path string Absolute file path
    ---@return neotest.Tree | nil
    function adapter.discover_positions(file_path)
        return require("neotest-ruby-minitest.positions").discover_positions(file_path)
    end

    ---@param args neotest.RunArgs
    ---@return nil | neotest.RunSpec | neotest.RunSpec[]
    function adapter.build_spec(args)
        return require("neotest-ruby-minitest.command").build(cfg, args)
    end

    ---@async
    ---@param spec neotest.RunSpec
    ---@param result neotest.StrategyResult
    ---@param tree neotest.Tree
    ---@return table<string, neotest.Result>
    function adapter.results(spec, result, tree)
        return require("neotest-ruby-minitest.results").parse(spec, result, tree)
    end

    return adapter
end

local default_adapter = build_adapter(conf.resolve())
return setmetatable(default_adapter, {
    __call = function(_, opts)
        return build_adapter(conf.resolve(opts))
    end
})
