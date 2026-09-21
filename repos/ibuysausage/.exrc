" .exrc for nur-packages
" Requires: nvim 0.10+ (vim.system), git, nix (with flakes enabled for
" `nix run nixpkgs#nix-prefetch-github`).
"
" Drop this file at the root of your nur-packages repo, then in nvim run
" `:set exrc` (or set it globally in your main config) and trust the file
" the first time nvim asks (:trust).
"
" Open any ./pkgs/somepkg/default.nix and run :NurBump. It will:
"   1. read owner/repo out of the fetchFromGitHub{} block
"   2. find the newest commit on the repo's default branch (git ls-remote)
"   3. rewrite `version = "..."` to the short commit hash (rev = "${version}")
"   4. rewrite `sha256 = "..."` to the freshly prefetched sha256

lua << EOF
local function get_owner_repo()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local text = table.concat(lines, "\n")
  local owner = text:match('owner%s*=%s*"([^"]+)"')
  local repo = text:match('repo%s*=%s*"([^"]+)"')
  return owner, repo
end

-- Replace the first `<field> = "...";` occurrence in the buffer.
local function set_field(field, value)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local pattern = "(" .. field .. "%s*=%s*)\"[^\"]*\""
  for i, line in ipairs(lines) do
    local new_line, n = line:gsub(pattern, "%1\"" .. value .. "\"")
    if n > 0 then
      vim.api.nvim_buf_set_lines(0, i - 1, i, false, { new_line })
      return true
    end
  end
  return false
end

local function notify_err(msg)
  vim.schedule(function()
    vim.notify("NurBump: " .. msg, vim.log.levels.ERROR)
  end)
end

local function nur_bump()
  local owner, repo = get_owner_repo()
  if not owner or not repo then
    vim.notify("NurBump: couldn't find owner/repo in fetchFromGitHub{}", vim.log.levels.ERROR)
    return
  end

  vim.notify(("NurBump: %s/%s — checking newest commit..."):format(owner, repo))

  -- 1+2: newest commit on the default branch
  vim.system(
    { "git", "ls-remote", ("https://github.com/%s/%s"):format(owner, repo), "HEAD" },
    { text = true },
    function(ls_remote)
      if ls_remote.code ~= 0 then
        notify_err("git ls-remote failed: " .. (ls_remote.stderr or ""))
        return
      end

      local full_sha = ls_remote.stdout and ls_remote.stdout:match("^(%x+)")
      if not full_sha then
        notify_err("couldn't parse commit sha from ls-remote output")
        return
      end
      local short_sha = full_sha:sub(1, 7)

      -- prefetch sha256 for that exact commit
      vim.system(
        { "nix", "run", "nixpkgs#nix-prefetch-github", "--", owner, repo, "--rev", full_sha },
        { text = true },
        function(prefetch)
          if prefetch.code ~= 0 then
            notify_err("nix-prefetch-github failed: " .. (prefetch.stderr or ""))
            return
          end

          local ok, data = pcall(vim.json.decode, prefetch.stdout or "")
          if not ok or not data then
            notify_err("couldn't parse nix-prefetch-github JSON output")
            return
          end

          -- newer nix-prefetch-github emits `hash` (SRI, sha256-...=);
          -- older versions emit `sha256` (base32). Prefer SRI.
          local hash = data.hash or data.sha256
          if not hash then
            notify_err("no hash/sha256 field in prefetch output")
            return
          end

          vim.schedule(function()
            -- 3: version = "<short-sha>" (rev = "${version}" picks this up)
            local ok_v = set_field("version", short_sha)
            -- 4: sha256 = "<hash>"
            local ok_s = set_field("sha256", hash)

            if ok_v and ok_s then
              vim.notify(("NurBump: updated to %s (%s)"):format(short_sha, hash))
            else
              vim.notify(
                ("NurBump: updated partially (version=%s sha256=%s) — check the file"):format(
                  tostring(ok_v),
                  tostring(ok_s)
                ),
                vim.log.levels.WARN
              )
            end
          end)
        end
      )
    end
  )
end

vim.api.nvim_buf_create_user_command(0, "NurBump", nur_bump, {
  desc = "Bump version/sha256 in a fetchFromGitHub default.nix to the newest commit",
})
EOF
