# Wrist May Cry

Vim is all about making text editing as efficient and ergonomic as possible. But what if it was optimal not to always edit optimally? WMC is a Neovim plugin that encourages variety in used motions through *Devil May Cry*-inspired style ranks.

## Showcase



## Requirements

- Neovim >= 0.11.0

## Installation

### [lazy](https://github.com/folke/lazy.nvim)

```lua
{
    "pakut2/wmc.nvim",
    lazy = false,
    version = "*", -- use `branch = "main"`, to reference the latest unstable changes
}
```

### [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim)

```shell
:Rocks install wmc.nvim
```

## Configuration

> [!NOTE]
> Calling the `setup` function is optional.

### Default Settings

```lua
require("wmc").setup({
	enabled = true,
	ui = {
		anchor = "NE",
		row = 1,
		col = function()
			return vim.o.columns - 5
		end,
		zindex = 50,
		border = "none",
	},
	logger = {
		enabled = false,
		log_file_path = vim.fn.stdpath("data") .. "/wmc.log",
	},
})
```

| Option  | Explanation |
|-|-|
| enabled | Toggle `wmc` |
| ui      | Configure style rank display window (partially derived from `vim.api.keyset.win_config`). `row` and `col` support passing a function for dynamic Neovim window resize handling |
| logger  | Toggle debug logging and change log destination |

## Development

- **Formatter** - [stylua](https://github.com/JohnnyMorganz/StyLua)
- **Linter** - [luacheck](https://github.com/mpeterv/luacheck)
- **Pre-Commit hooks** - [pre-commit](https://pre-commit.com)

### Running tests

Tests are executed with Neovim as the Lua interpreter with [busted](https://lunarmodules.github.io/busted).

#### Install Test Dependencies

```shell
luarocks install --tree lua_modules --lua-version 5.1 nlua
luarocks install --tree lua_modules --lua-version 5.1 busted
```

#### Run Tests

```shell
eval "$(luarocks path --tree lua_modules --lua-version 5.1)"
luarocks test --lua-version 5.1
```

