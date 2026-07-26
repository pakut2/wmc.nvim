rockspec_format = "3.0"
package = "wmc.nvim"
version = "scm-1"
source = {
	url = "git+https://github.com/pakut2/" .. package,
}
description = {
	summary = "Edit with STYLE in Neovim",
	labels = { "neovim", "neovim-plugin", "wmc" },
	homepage = "https://github.com/pakut2/" .. package,
	license = "MIT",
}
dependencies = {
	"lua >= 5.1, < 5.2",
}
test_dependencies = {
	"busted",
	"nlua",
}
build = {
	type = "builtin",
	copy_directories = {
		"plugin",
	},
}
