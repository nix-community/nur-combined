" .exrc for nur-packages
" Requires: nvim 0.10+ (vim.system), git, nix (with flakes enabled for
" `nix run nixpkgs#nix-prefetch-github`).
"
" Drop this file at the root of your nur-packages repo as `.exrc`, then in nvim
" run `:set exrc` (or set it globally in your main config) and trust the file
" the first time nvim asks (:trust).
"
" :NurBump
"   Open any ./pkgs/somepkg/default.nix and run :NurBump. It will:
"   1. read owner/repo out of the fetchFromGitHub{} block
"   2. find the newest commit on the repo's default branch (git ls-remote)
"   3. rewrite `version = "..."` to the short commit hash (rev = "${version}")
"   4. rewrite `sha256 = "..."` (or `hash = "..."`) to the freshly prefetched hash
"   The change is made in the current buffer; it is not saved for you.
"
" :NurBumpAll[!]
"   Finds the pkgs/ directory (walking up from the current buffer, falling back
"   to the cwd), then does the same as :NurBump for every pkgs/*/default.nix.
"   A report buffer opens and fills in live: package, repo, old -> new commit,
"   new sha256 and status. Files are written to disk; any of them that are open
"   in a buffer get reloaded. Packages whose buffer has unsaved changes are
"   skipped. Packages already on the newest commit are left alone, unless you
"   use :NurBumpAll! to force a re-prefetch. Press q in the report to close it.

lua << EOF
local MAX_PARALLEL = 4 -- how many packages are checked/prefetched at once

---------------------------------------------------------------------------
-- helpers that operate on a list of lines (a buffer's or a file's)
---------------------------------------------------------------------------
local function parse_fields(lines)
  local text = table.concat(lines, "\n")
  local owner = text:match('%f[%w_]owner%s*=%s*"([^"]+)"')
  local repo = text:match('%f[%w_]repo%s*=%s*"([^"]+)"')
  local version = text:match('%f[%w_]version%s*=%s*"([^"]*)"')
  return owner, repo, version
end

-- Replace the first `<field> = "...";` occurrence in `lines` (in place).
local function set_field(lines, field, value)
  local pattern = "(%f[%w_]" .. field .. "%s*=%s*)\"[^\"]*\""
  local repl = "%1\"" .. (value:gsub("%%", "%%%%")) .. "\""
  for i, line in ipairs(lines) do
    local new_line, n = line:gsub(pattern, repl)
    if n > 0 then
      lines[i] = new_line
      return true
    end
  end
  return false
end

-- version -> short sha, sha256 (or hash) -> prefetched hash.
local function apply_bump(lines, short_sha, hash)
  local ok_v = set_field(lines, "version", short_sha)
  local ok_s = set_field(lines, "sha256", hash) or set_field(lines, "hash", hash)
  return ok_v, ok_s
end

local function last_line(s)
  local last = ""
  for line in vim.gsplit(s or "", "\n", { plain = true }) do
    if vim.trim(line) ~= "" then
      last = vim.trim(line)
    end
  end
  return last
end

local function notify_err(msg)
  vim.schedule(function()
    vim.notify("NurBump: " .. msg, vim.log.levels.ERROR)
  end)
end

---------------------------------------------------------------------------
-- network side. Callbacks are always invoked on the main loop, so they can
-- freely use the nvim API. cb(err) or cb(nil, result).
---------------------------------------------------------------------------
local function latest_commit(owner, repo, cb)
  vim.system(
    { "git", "ls-remote", ("https://github.com/%s/%s"):format(owner, repo), "HEAD" },
    { text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 then
        return cb("git ls-remote failed: " .. last_line(res.stderr))
      end
      local full_sha = res.stdout and res.stdout:match("^(%x+)")
      if not full_sha then
        return cb("couldn't parse commit sha from ls-remote output")
      end
      cb(nil, full_sha)
    end)
  )
end

local function prefetch_hash(owner, repo, rev, cb)
  vim.system(
    { "nix", "run", "nixpkgs#nix-prefetch-github", "--", owner, repo, "--rev", rev },
    { text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 then
        return cb("nix-prefetch-github failed: " .. last_line(res.stderr))
      end
      local ok, data = pcall(vim.json.decode, res.stdout or "")
      if not ok or type(data) ~= "table" then
        return cb("couldn't parse nix-prefetch-github JSON output")
      end
      -- newer nix-prefetch-github emits `hash` (SRI, sha256-...=);
      -- older versions emit `sha256` (base32). Prefer SRI.
      local hash = data.hash or data.sha256
      if not hash then
        return cb("no hash/sha256 field in prefetch output")
      end
      cb(nil, hash)
    end)
  )
end

---------------------------------------------------------------------------
-- :NurBump  (current buffer only)
---------------------------------------------------------------------------
local function nur_bump()
  local buf = vim.api.nvim_get_current_buf()
  local owner, repo = parse_fields(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
  if not owner or not repo then
    vim.notify("NurBump: couldn't find owner/repo in fetchFromGitHub{}", vim.log.levels.ERROR)
    return
  end

  vim.notify(("NurBump: %s/%s — checking newest commit..."):format(owner, repo))

  latest_commit(owner, repo, function(err, full_sha)
    if err then
      return notify_err(err)
    end
    local short_sha = full_sha:sub(1, 7)

    prefetch_hash(owner, repo, full_sha, function(err2, hash)
      if err2 then
        return notify_err(err2)
      end
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      -- re-read the buffer: it may have changed while we were waiting
      local old = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local new = vim.deepcopy(old)
      local ok_v, ok_s = apply_bump(new, short_sha, hash)
      for i, line in ipairs(new) do
        if line ~= old[i] then
          vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { line })
        end
      end

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
  end)
end

---------------------------------------------------------------------------
-- :NurBumpAll
---------------------------------------------------------------------------
local function find_pkgs_dir()
  local name = vim.api.nvim_buf_get_name(0)
  local start = (name ~= "") and vim.fs.dirname(name) or vim.fn.getcwd()
  local found = vim.fs.find("pkgs", { path = start, upward = true, type = "directory", limit = 1 })[1]
  if found then
    return found
  end
  local fallback = vim.fn.getcwd() .. "/pkgs"
  if vim.fn.isdirectory(fallback) == 1 then
    return fallback
  end
  return nil
end

local function loaded_buf_for(path)
  path = vim.fs.normalize(path)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.fs.normalize(vim.api.nvim_buf_get_name(b)) == path then
      return b
    end
  end
  return nil
end

local function pad(s, w)
  return s .. string.rep(" ", math.max(0, w - vim.fn.strdisplaywidth(s)))
end

local function open_report(nrows)
  -- close a report from a previous run, if it's still around
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.b[b].nurbump_report then
      pcall(vim.api.nvim_buf_delete, b, { force = true })
    end
  end

  vim.cmd(("botright %dnew"):format(math.min(nrows + 6, 20)))
  local buf = vim.api.nvim_get_current_buf()
  vim.b[buf].nurbump_report = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "nurbump"
  vim.bo[buf].modifiable = false
  pcall(vim.api.nvim_buf_set_name, buf, "NurBumpAll")
  vim.wo.wrap = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  return buf
end

-- Run worker(item, done) over items with at most `limit` in flight.
local function run_pool(items, limit, worker, on_done)
  local total, next_i, running, finished = #items, 1, 0, 0
  if total == 0 then
    return on_done()
  end
  local function launch()
    while running < limit and next_i <= total do
      local item = items[next_i]
      next_i = next_i + 1
      running = running + 1
      worker(item, function()
        running = running - 1
        finished = finished + 1
        if finished == total then
          on_done()
        else
          launch()
        end
      end)
    end
  end
  launch()
end

local function nur_bump_all(force)
  local pkgs_dir = find_pkgs_dir()
  if not pkgs_dir then
    return notify_err("couldn't find a pkgs/ directory above this buffer or in the cwd")
  end
  local files = vim.fn.glob(pkgs_dir .. "/*/default.nix", false, true)
  if #files == 0 then
    return notify_err("no pkgs/*/default.nix found under " .. pkgs_dir)
  end

  local rows = {}
  for _, path in ipairs(files) do
    rows[#rows + 1] = {
      path = path,
      name = vim.fn.fnamemodify(path, ":h:t"),
      state = "pending", -- pending | running | updated | current | skipped | failed
      status = "pending",
    }
  end

  local buf = open_report(#rows)

  local function render()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    local header = { "package", "repo", "commit", "sha256" }
    local widths = {}
    for i, h in ipairs(header) do
      widths[i] = vim.fn.strdisplaywidth(h)
    end

    local counts = { updated = 0, current = 0, skipped = 0, failed = 0 }
    local finished = 0
    local body = {}
    for _, r in ipairs(rows) do
      local commit = ""
      if r.old or r.new then
        commit = (r.old or "?") .. " -> " .. (r.new or "...")
      end
      local cells = { r.name, r.repo or "", commit, r.hash or "" }
      for i, c in ipairs(cells) do
        widths[i] = math.max(widths[i], vim.fn.strdisplaywidth(c))
      end
      body[#body + 1] = { cells = cells, status = r.status }
      if counts[r.state] then
        counts[r.state] = counts[r.state] + 1
        finished = finished + 1
      end
    end

    local function fmt(cells, status)
      local parts = {}
      for i, c in ipairs(cells) do
        parts[i] = pad(c, widths[i])
      end
      return table.concat(parts, "  ") .. "  " .. status
    end

    local out = { "NurBumpAll  " .. pkgs_dir, "" }
    out[#out + 1] = fmt(header, "status")
    out[#out + 1] = string.rep("-", vim.fn.strdisplaywidth(out[#out]))
    for _, b in ipairs(body) do
      out[#out + 1] = fmt(b.cells, b.status)
    end
    out[#out + 1] = ""
    if finished < #rows then
      out[#out + 1] = ("Working... %d/%d finished"):format(finished, #rows)
    else
      out[#out + 1] = ("Done: %d updated, %d up to date, %d skipped, %d failed   (q to close)"):format(
        counts.updated,
        counts.current,
        counts.skipped,
        counts.failed
      )
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
    vim.bo[buf].modifiable = false
  end

  local function set(row, state, status)
    row.state, row.status = state, status
    render()
  end

  local function process(row, done)
    local owner, repo, version = parse_fields(vim.fn.readfile(row.path))
    if not owner or not repo then
      set(row, "skipped", "no fetchFromGitHub owner/repo found")
      return done()
    end
    row.repo, row.old = owner .. "/" .. repo, version
    set(row, "running", "checking newest commit...")

    latest_commit(owner, repo, function(err, full_sha)
      if err then
        set(row, "failed", err)
        return done()
      end
      row.new = full_sha:sub(1, 7)
      if row.old == row.new and not force then
        set(row, "current", "up to date")
        return done()
      end

      set(row, "running", "prefetching sha256...")
      prefetch_hash(owner, repo, full_sha, function(err2, hash)
        if err2 then
          set(row, "failed", err2)
          return done()
        end
        row.hash = hash

        local bufnr = loaded_buf_for(row.path)
        if bufnr and vim.bo[bufnr].modified then
          set(row, "skipped", "buffer has unsaved changes (new sha256 shown above)")
          return done()
        end

        -- re-read from disk right before writing
        local lines = vim.fn.readfile(row.path)
        local ok_v, ok_s = apply_bump(lines, row.new, hash)
        if not (ok_v and ok_s) then
          set(row, "failed", "couldn't find " .. (ok_v and "a sha256/hash" or "a version") .. " field to rewrite")
          return done()
        end
        if vim.fn.writefile(lines, row.path) ~= 0 then
          set(row, "failed", "couldn't write file")
          return done()
        end
        if bufnr then
          vim.api.nvim_buf_call(bufnr, function()
            vim.cmd("silent! edit")
          end)
        end
        set(row, "updated", "updated")
        done()
      end)
    end)
  end

  render()
  run_pool(rows, MAX_PARALLEL, process, render)
end

vim.api.nvim_create_user_command("NurBump", nur_bump, {
  desc = "Bump version/sha256 in a fetchFromGitHub default.nix to the newest commit",
})

vim.api.nvim_create_user_command("NurBumpAll", function(opts)
  nur_bump_all(opts.bang)
end, {
  bang = true,
  desc = "Bump every pkgs/*/default.nix to its newest commit and show a report (! = force)",
})
EOF
