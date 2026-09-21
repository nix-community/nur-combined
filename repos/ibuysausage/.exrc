" .exrc for nur-packages
" Requires: nvim 0.10+ (vim.system, float footers), git, nix (with flakes
" enabled for `nix run nixpkgs#nix-prefetch-github`).
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
"   A report opens in a floating window (REPORT_SCALE below) and fills in live:
"   a colored table with package, repo, old -> new commit, new sha256 and
"   status, plus a progress bar and per-state counts. The table always spans the
"   full width of the window: spare room goes to the status column, and when
"   space is tight the columns shrink (and their text is elided) in the order
"   given by SHRINK_ORDER, down to MIN_WIDTHS. Resizing nvim re-lays it out.
"   Files are written to disk; any of them that are open in a buffer get
"   reloaded. Packages whose buffer has unsaved changes are skipped. Packages
"   already on the newest commit are left alone, unless you use :NurBumpAll! to
"   force a re-prefetch. Press q or <Esc> in the report to close it.
"
"   Colors: every NurBump* highlight group links to a standard group, so the
"   report follows your colorscheme. Override any of them from your own config,
"   e.g. vim.api.nvim_set_hl(0, "NurBumpPkg", { fg = "#ff9e64", bold = true })

lua << EOF
local MAX_PARALLEL = 4 -- how many packages are checked/prefetched at once
local REPORT_SCALE = 0.8 -- report window size as a fraction of the editor (1.0 = whole screen)

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

---------------------------------------------------------------------------
-- report window: colors, layout helpers
---------------------------------------------------------------------------
local hl_ns = vim.api.nvim_create_namespace("nurbump")

-- Every group links to a standard one (default = true), so the report follows
-- your colorscheme and anything you define yourself beforehand wins.
local function setup_highlights()
  local links = {
    NurBumpPath = "Comment", -- pkgs/ directory line
    NurBumpSep = "Special", -- table borders and rules
    NurBumpHeader = "Title", -- column titles
    NurBumpPkg = "Function", -- package name
    NurBumpRepo = "Identifier", -- owner/repo
    NurBumpOld = "Comment", -- old commit
    NurBumpArrow = "Operator", -- the arrow between old and new
    NurBumpNew = "Constant", -- new commit
    NurBumpHash = "String", -- new sha256
    NurBumpPending = "Comment",
    NurBumpRunning = "DiagnosticHint",
    NurBumpUpdated = "DiagnosticOk",
    NurBumpCurrent = "DiagnosticInfo",
    NurBumpSkipped = "DiagnosticWarn",
    NurBumpFailed = "DiagnosticError",
    NurBumpBarDone = "DiagnosticOk", -- progress bar, filled part
    NurBumpBarTodo = "Comment", -- progress bar, empty part
  }
  for name, target in pairs(links) do
    vim.api.nvim_set_hl(0, name, { link = target, default = true })
  end
end

local STATES = {
  pending = { icon = "·", label = "pending", hl = "NurBumpPending" },
  running = { icon = "…", label = "running", hl = "NurBumpRunning" },
  updated = { icon = "✓", label = "updated", hl = "NurBumpUpdated" },
  current = { icon = "●", label = "up to date", hl = "NurBumpCurrent" },
  skipped = { icon = "!", label = "skipped", hl = "NurBumpSkipped" },
  failed = { icon = "✗", label = "failed", hl = "NurBumpFailed" },
}

-- A line is a list of chunks { text, hl_group? }. Returns the joined string and
-- the highlight spans { start_byte, end_byte, hl_group } for it.
local function build_line(chunks)
  local parts, spans, col = {}, {}, 0
  for _, c in ipairs(chunks) do
    local text, hl = c[1], c[2]
    parts[#parts + 1] = text
    if hl and #text > 0 then
      spans[#spans + 1] = { col, col + #text, hl }
    end
    col = col + #text
  end
  return table.concat(parts), spans
end

local function chunks_width(chunks)
  local w = 0
  for _, c in ipairs(chunks) do
    w = w + vim.fn.strdisplaywidth(c[1])
  end
  return w
end

-- Cut a chunk list down to `width` display cells, marking the cut with "…".
local function fit_chunks(chunks, width)
  if chunks_width(chunks) <= width then
    return chunks
  end
  local out, used = {}, 0
  for _, c in ipairs(chunks) do
    local w = vim.fn.strdisplaywidth(c[1])
    if used + w <= width then
      out[#out + 1] = c
      used = used + w
    else
      local room = width - used - 1 -- keep a cell for the ellipsis
      if room > 0 then
        out[#out + 1] = { vim.fn.strcharpart(c[1], 0, room) .. "…", c[2] }
      elseif width - used > 0 then
        out[#out + 1] = { "…", c[2] }
      end
      break
    end
  end
  return out
end

-- One table row: cells are chunk lists, elided/padded to `widths` and split by
-- " │ ". The last cell is padded too, so every row is exactly as wide as the
-- rules above and below it.
local function row_chunks(cells, widths)
  local out = { { " " } }
  for i, cell in ipairs(cells) do
    local fitted = fit_chunks(cell, widths[i])
    for _, c in ipairs(fitted) do
      out[#out + 1] = c
    end
    out[#out + 1] = { string.rep(" ", math.max(0, widths[i] - chunks_width(fitted))) }
    if i < #cells then
      out[#out + 1] = { " │ ", "NurBumpSep" }
    end
  end
  return out
end

local function commit_chunks(r)
  if not (r.old or r.new) then
    return {}
  end
  return {
    { r.old or "?", "NurBumpOld" },
    { " → ", "NurBumpArrow" },
    { r.new or "...", "NurBumpNew" },
  }
end

-- Position/size of the floating window, recomputed on resize.
local function float_geometry()
  local cols = vim.o.columns
  local rows = vim.o.lines - vim.o.cmdheight - (vim.o.laststatus > 0 and 1 or 0)
  local width = math.min(cols - 2, math.max(40, math.floor((cols - 2) * REPORT_SCALE)))
  local height = math.min(rows - 2, math.max(8, math.floor((rows - 2) * REPORT_SCALE)))
  return {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((cols - width - 2) / 2),
    row = math.floor((rows - height - 2) / 2),
  }
end

-- Usable text width of the report: the window's own width while it's open,
-- otherwise the width it would get.
local function report_width(buf)
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) == buf then
      return vim.api.nvim_win_get_width(w)
    end
  end
  return float_geometry().width
end

-- hooks.on_resize, if set, is called after the window has been re-sized.
local function open_report(hooks)
  -- close a report from a previous run, if it's still around
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.b[b].nurbump_report then
      pcall(vim.api.nvim_buf_delete, b, { force = true })
    end
  end

  setup_highlights()

  local buf = vim.api.nvim_create_buf(false, true) -- unlisted scratch buffer
  vim.b[buf].nurbump_report = true
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "nurbump"
  vim.bo[buf].modifiable = false
  pcall(vim.api.nvim_buf_set_name, buf, "NurBumpAll")

  local win = vim.api.nvim_open_win(
    buf,
    true,
    vim.tbl_extend("force", float_geometry(), {
      style = "minimal",
      border = "rounded",
      title = " NurBumpAll ",
      title_pos = "center",
      footer = " q / <Esc> to close ",
      footer_pos = "right",
    })
  )
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  vim.wo[win].spell = false -- no spell-check squiggles on package names and hashes

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, close, { buffer = buf, silent = true, nowait = true })
  end

  -- keep the window sized to the editor and re-lay out the table for the new
  -- width; the autocmd removes itself once the window is gone. (Only geometry
  -- is passed, so `style` isn't re-applied.)
  vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("NurBumpReport", { clear = true }),
    callback = function()
      if not vim.api.nvim_win_is_valid(win) then
        return true
      end
      vim.api.nvim_win_set_config(win, float_geometry())
      if hooks and hooks.on_resize then
        hooks.on_resize()
      end
    end,
  })

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

  local hooks = {}
  local buf = open_report(hooks)
  local headers = { "package", "repo", "commit", "sha256", "status" }
  -- how the table adapts to the window width
  local GROW_COL = 5 -- spare width goes to the status column
  local SHRINK_ORDER = { 5, 2, 1, 3, 4 } -- columns give width up in this order
  local MIN_WIDTHS = { 8, 10, 12, 16, 8 } -- and never below this
  local BAR_MIN = 10 -- progress bar never gets narrower than this

  local function render()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    -- cells are chunk lists; column widths start from the widest cell
    local header_cells, widths = {}, {}
    for i, h in ipairs(headers) do
      header_cells[i] = { { h, "NurBumpHeader" } }
      widths[i] = chunks_width(header_cells[i])
    end

    local counts = { updated = 0, current = 0, skipped = 0, failed = 0 }
    local finished = 0
    local body = {}
    for _, r in ipairs(rows) do
      local st = STATES[r.state]
      local cells = {
        { { r.name, "NurBumpPkg" } },
        { { r.repo or "", "NurBumpRepo" } },
        commit_chunks(r),
        { { r.hash or "", "NurBumpHash" } },
        { { st.icon .. " " .. r.status, st.hl } },
      }
      for i, cell in ipairs(cells) do
        widths[i] = math.max(widths[i], chunks_width(cell))
      end
      body[#body + 1] = cells
      if counts[r.state] then
        counts[r.state] = counts[r.state] + 1
        finished = finished + 1
      end
    end

    -- stretch (or squeeze) the columns so the table spans the whole window: a
    -- row is a leading space, the columns, and " │ " between each pair.
    local target = report_width(buf) - (3 * #widths - 2)
    local natural = 0
    for _, w in ipairs(widths) do
      natural = natural + w
    end
    if natural < target then
      widths[GROW_COL] = widths[GROW_COL] + (target - natural)
    elseif natural > target then
      local over = natural - target
      for _, i in ipairs(SHRINK_ORDER) do
        if over <= 0 then
          break
        end
        local give = math.min(over, math.max(0, widths[i] - MIN_WIDTHS[i]))
        widths[i] = widths[i] - give
        over = over - give
      end
    end

    -- horizontal rule with `mid` as the column crossing (┼ or ┴)
    local function rule(mid)
      local segs = {}
      for i, w in ipairs(widths) do
        segs[i] = string.rep("─", w + (i == #widths and 1 or 2))
      end
      return table.concat(segs, mid)
    end
    local total = vim.fn.strdisplaywidth(rule("┼"))

    local lines, spans = {}, {}
    local function add(chunks)
      local text, sp = build_line(chunks)
      lines[#lines + 1] = text
      spans[#lines] = sp
    end

    local top = { { " " }, { vim.fn.fnamemodify(pkgs_dir, ":~"), "NurBumpPath" } }
    if force then
      top[#top + 1] = { "   forced: re-prefetching everything", "NurBumpSkipped" }
    end
    add(fit_chunks(top, total))
    add({ { string.rep("━", total), "NurBumpSep" } })
    add(row_chunks(header_cells, widths))
    add({ { rule("┼"), "NurBumpSep" } })
    for _, cells in ipairs(body) do
      add(row_chunks(cells, widths))
    end
    add({ { rule("┴"), "NurBumpSep" } })
    add({})

    -- counts first, then let the progress bar take all the width that's left
    local right = { { ("  %d/%d   "):format(finished, #rows) } }
    for _, key in ipairs({ "updated", "current", "skipped", "failed" }) do
      local st = STATES[key]
      right[#right + 1] = { ("%s %d %s   "):format(st.icon, counts[key], st.label), st.hl }
    end
    if finished == #rows then
      right[#right + 1] = { "done", "NurBumpUpdated" }
    else
      right[#right + 1] = { "working…", "NurBumpRunning" }
    end

    local bar = math.max(BAR_MIN, total - 1 - chunks_width(right))
    local filled = math.floor(bar * finished / #rows)
    local summary = {
      { " " },
      { string.rep("█", filled), "NurBumpBarDone" },
      { string.rep("░", bar - filled), "NurBumpBarTodo" },
    }
    for _, c in ipairs(right) do
      summary[#summary + 1] = c
    end
    add(fit_chunks(summary, total))

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(buf, hl_ns, 0, -1)
    for i, sp in ipairs(spans) do
      for _, s in ipairs(sp) do
        vim.api.nvim_buf_set_extmark(buf, hl_ns, i - 1, s[1], { end_col = s[2], hl_group = s[3] })
      end
    end
  end

  hooks.on_resize = render

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
