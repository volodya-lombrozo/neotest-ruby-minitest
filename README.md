# neotest-ruby-minitest

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Lint](https://github.com/volodya-lombrozo/neotest-ruby-minitest/actions/workflows/lint.yml/badge.svg)](https://github.com/volodya-lombrozo/neotest-ruby-minitest/actions/workflows/lint.yml)
[![Tests](https://github.com/volodya-lombrozo/neotest-ruby-minitest/actions/workflows/test.yml/badge.svg)](https://github.com/volodya-lombrozo/neotest-ruby-minitest/actions/workflows/test.yml)

A [Minitest](https://docs.seattlerb.org/minitest/) adapter for [Neotest](https://github.com/nvim-neotest/neotest).
It’s inspired by the [neotest-minitest](https://github.com/nvim-neotest/neotest-minitest) adapter but re-implements parts of its logic to address [known issues](https://github.com/zidhuss/neotest-minitest/issues/36) — particularly compatibility problems with custom reporters — allowing you to use any reporter you prefer.
In addition, it improves [test discovery](https://github.com/zidhuss/neotest-minitest/issues/37), resulting in more accurate detection of tests across Rails and plain Ruby projects.

## Installation

**Lazy**

```lua
{
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    ...,
    "volodya-lombrozo/neotest-ruby-minitest",
  },
  config = function()
    require("neotest").setup({
      ...,
      adapters = {
        require("neotest-ruby-minitest")
      },
    })
  end
}
```

## Configuration

### Default

```lua
adapters = {
  require("neotest-minitest")({
    command = "ruby -Itest"
  }),
}
```

Usually, you don't need to modify the default configuration. However, if required, you can change 
the default command:

```lua
adapters = {
  require("neotest-minitest")({
    command = "bundle exec ruby -Itest"
  })
}
```

## How to Contribute

Fork the repository, make changes, and submit a pull request. We will review your changes and merge them into the `main` branch if they meet our quality standards. 
To avoid delays, please ensure that the entire build passes before submitting your pull request:

```bash
make test
make lint
```

