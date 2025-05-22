-- add to ~/.vimrc to enable file-type detection for `nix-shell` scripts,
-- e.g. files with `#!nix-shell -i python3 -p python3 -p ...` are recognized as `python` files

-- see <https://neovim.io/doc/user/lua.html#vim.filetype.add()>
vim.filetype.add {
  pattern = {
    ['.*'] = {
      function(path, bufnr)
        -- returns true if the input is a shebang likely to evaluate to `nix-shell`, e.g.
        -- - "#!/usr/bin/env nix-shell"  => true
        -- - "#!nix-shell -i bash -p coreutils"  => true
        -- - "#!/usr/bin/env python"  => false
        function test_for_nix_shell_shebang(maybe_hashbang)
          local bang_payload = string.match(maybe_hashbang, '^#!(.*)$')
          if not bang_payload then
            return false -- not a shebang
          end
          -- look for `nix-shell` _as its own word_ anywhere in the shebang line
          for word in string.gmatch(bang_payload, "[^ ]+") do
            if word == "nix-shell" then
              return true
            end
          end
        end

        -- extract `$interpreter` from some `#!nix-shell -i $interpreter ...` line.
        -- returns `nil` if no `-i $interpreter` was specified.
        -- - "#!nix-shell -i my-beautiful-int -p foo" => "my-beautiful-int"
        -- - "#!nix-shell -p python3 -i python" => "python"
        -- - "#!/usr/bin/env python" => nil
        -- - "#!nix-shell -p python" => nil
        function parse_nix_shell(maybe_nix_shell)
          local shell_payload = string.match(maybe_nix_shell, "^#!nix%-shell(.*)$")

          if not shell_payload then
            return
          end

          local interpreters = {}
          local context = nil
          for word in string.gmatch(shell_payload, "[^ ]+") do
            if context == "-i" then
              table.insert(interpreters, word)
              context = nil
            elseif word == "-i" then
              context = "-i"
            end
            -- this parser doesn't consider _all_ nix flags, and especially things like quotes, etc.
            -- just keep your nix-shell lines simple...
          end

          return interpreters[1]
        end

        -- given an interpreter (basename), guess a suitable vim filetype.
        -- for many languages, these are equivalent and this function is a no-op.
        -- "python2.7" => "python"
        -- "bash"  => "bash"
        -- "totally-unknown" => "totally-unknown"
        function filetype_from_interpreter(i)
          -- list of known vim filetypes may be found in <repo:neovim/neovim:runtime/lua/vim/filetype.lua>
          if string.match(i, "^python") then
            -- python3, python2.7, etc
            return "python"
          elseif i == "ysh" then
            -- XXX(2025-05-16): neovim has no `ysh`/oil-shell filetype.
            -- consider one of these filetypes:
            -- - "sh": but ysh curly braces will confuse the syntax highlighting
            -- - "csh": no highlighting bugs, just omits some highlights
            -- - "cpp": better highlighting of functions, but thinks `#` comments are compiler directives
            -- - "fish": highlights a LOT, but still occasional bugs
            -- - "zsh": slightly more capable than csh; no bugs
            return "zsh"
          else
            -- very common for interpreter name to be the same as filetype
            return i
          end
        end

        -- docs: <https://neovim.io/doc/user/api.html#nvim_buf_get_lines()>
        -- nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
        -- `start` and `end` are inclusive
        local first_few_lines = vim.api.nvim_buf_get_lines(bufnr, 0, 5, false)
        local maybe_hashbang = first_few_lines[1] or ''

        if not test_for_nix_shell_shebang(maybe_hashbang) then
          return
        end

        -- search for `#!nix-shell -i $interpreter ...` anywhere in the first few lines of the file
        for _, line in ipairs(first_few_lines) do
          local interpreter = parse_nix_shell(line)
          if interpreter then
            return filetype_from_interpreter(interpreter)
          end
        end
      end,
      -- high priority, to overrule vim's native detection (which gives ft=nix to all nix-shell files)
      { priority = math.huge },
    },
  },
}
