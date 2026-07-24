# Wrist May Cry

> [!NOTE]
> WIP

## Development

- **Formatter** - [stylua](https://github.com/JohnnyMorganz/StyLua)
- **Linter** - [luacheck](https://github.com/mpeterv/luacheck)

### Running tests

Tests are executed with Neovim as the Lua interpreter with [busted](https://lunarmodules.github.io/busted).

1. Install Test Dependencies

```shell
luarocks install --tree lua_modules --lua-version 5.1 nlua
luarocks install --tree lua_modules --lua-version 5.1 busted
```

2. Run Tests

```shell
eval "$(luarocks path --tree lua_modules --lua-version 5.1)"
luarocks test --lua-version 5.1
```

