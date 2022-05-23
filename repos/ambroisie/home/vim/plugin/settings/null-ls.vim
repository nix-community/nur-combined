lua << EOF
local null_ls = require("null-ls")
local lsp = require("ambroisie.lsp")
local utils = require("ambroisie.utils")

null_ls.setup({
    on_attach = lsp.on_attach,
})

-- C, C++
null_ls.register({
    null_ls.builtins.formatting.clang_format.with({
        -- Only used if available, but prefer clangd formatting if available
        condition = function()
            return utils.is_executable("clang-format") and not utils.is_executable("clangd")
        end,
    }),
})

-- Haskell
null_ls.register({
    null_ls.builtins.formatting.brittany.with({
        -- Only used if available
        condition = utils.is_executable_condition("brittany"),
    }),
})

-- Nix
null_ls.register({
    null_ls.builtins.formatting.nixpkgs_fmt.with({
        -- Only used if available, but prefer rnix if available
        condition = function()
            return utils.is_executable("nixpkgs-fmt") and not utils.is_executable("rnix-lsp")
        end,
    }),
})

-- Python
null_ls.register({
    null_ls.builtins.diagnostics.flake8.with({
        -- Only used if available, but prefer pflake8 if available
        condition = function()
            return utils.is_executable("flake8") and not utils.is_executable("pflake8")
        end,
    }),
    null_ls.builtins.diagnostics.pyproject_flake8.with({
        -- Only used if available
        condition = utils.is_executable_condition("pflake8"),
    }),
    null_ls.builtins.diagnostics.mypy.with({
        -- Only used if available
        condition = utils.is_executable_condition("mypy"),
    }),
    null_ls.builtins.diagnostics.pylint.with({
        -- Only used if available
        condition = utils.is_executable_condition("pylint"),
    }),
    null_ls.builtins.formatting.black.with({
        extra_args = { "--fast" },
        -- Only used if available
        condition = utils.is_executable_condition("black"),
    }),
    null_ls.builtins.formatting.isort.with({
        -- Only used if available
        condition = utils.is_executable_condition("isort"),
    }),
})


-- Shell (non-POSIX)
null_ls.register({
    null_ls.builtins.code_actions.shellcheck.with({
        -- Restrict to bash and zsh
        filetypes = { "bash", "zsh" },
        -- Only used if available
        condition = utils.is_executable_condition("shellcheck"),
    }),
    null_ls.builtins.diagnostics.shellcheck.with({
        -- Show error code in message
        diagnostics_format = "[#{c}] #{m}",
        -- Require explicit empty string test, use bash dialect
        extra_args = { "-s", "bash", "-o", "avoid-nullary-conditions" },
        -- Restrict to bash and zsh
        filetypes = { "bash", "zsh" },
        -- Only used if available
        condition = utils.is_executable_condition("shellcheck"),
    }),
    null_ls.builtins.formatting.shfmt.with({
        -- Indent with 4 spaces, simplify the code, indent switch cases,
        -- add space after redirection, use bash dialect
        extra_args = { "-i", "4", "-s", "-ci", "-sr", "-ln", "bash" },
        -- Restrict to bash and zsh
        filetypes = { "bash", "zsh" },
        -- Only used if available
        condition = utils.is_executable_condition("shfmt"),
    }),
})

-- Shell (POSIX)
null_ls.register({
    null_ls.builtins.code_actions.shellcheck.with({
    -- Restrict to POSIX sh
        filetypes = { "sh" },
        -- Only used if available
        condition = utils.is_executable_condition("shellcheck"),
    }),
    null_ls.builtins.diagnostics.shellcheck.with({
        -- Show error code in message
        diagnostics_format = "[#{c}] #{m}",
        -- Require explicit empty string test
        extra_args = { "-o", "avoid-nullary-conditions" },
        -- Restrict to POSIX sh
        filetypes = { "sh" },
        -- Only used if available
        condition = utils.is_executable_condition("shellcheck"),
    }),
    null_ls.builtins.formatting.shfmt.with({
        -- Indent with 4 spaces, simplify the code, indent switch cases,
        -- add space after redirection, use POSIX
        extra_args = { "-i", "4", "-s", "-ci", "-sr", "-ln", "posix" },
        -- Only used if available
        condition = utils.is_executable_condition("shfmt"),
    }),
})
EOF
