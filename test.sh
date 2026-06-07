#!/bin/bash

eval "$(luarocks path --tree lua_modules --lua-version 5.1)"
luarocks test --lua-version 5.1

