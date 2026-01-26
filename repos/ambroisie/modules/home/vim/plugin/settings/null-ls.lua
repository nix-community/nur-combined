local null_ls = require("null-ls")
local lsp = require("ambroisie.lsp")
local utils = require("ambroisie.utils")

null_ls.setup({
    on_attach = lsp.on_attach,
})

-- Bazel
null_ls.register({
    null_ls.builtins.diagnostics.buildifier.with({
        -- Only used if available
        condition = utils.partial(utils.is_executable, "buildifier"),
    }),
    null_ls.builtins.formatting.buildifier.with({
        -- Only used if available
        condition = utils.partial(utils.is_executable, "buildifier"),
    }),
})

-- Nix
null_ls.register({
    null_ls.builtins.formatting.nixpkgs_fmt.with({
        -- Only used if available
        condition = utils.partial(utils.is_executable, "nixpkgs-fmt"),
    }),
})

-- Python
null_ls.register({
    null_ls.builtins.diagnostics.mypy.with({
        -- Only used if available
        condition = utils.partial(utils.is_executable, "mypy"),
    }),
    null_ls.builtins.diagnostics.pylint.with({
        -- Only used if available
        condition = utils.partial(utils.is_executable, "pylint"),
    }),
    null_ls.builtins.formatting.black.with({
        extra_args = { "--fast" },
        -- Only used if available
        condition = utils.partial(utils.is_executable, "black"),
    }),
    null_ls.builtins.formatting.isort.with({
        -- Only used if available
        condition = utils.partial(utils.is_executable, "isort"),
    }),
})
