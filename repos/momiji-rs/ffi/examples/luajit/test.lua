-- sasso C ABI (FFI v2) binding + test harness for LuaJIT.
--
-- Loads the prebuilt libsasso shared library via LuaJIT's `ffi`, declares the
-- ABI from ffi/include/sasso.h, and asserts the five checks from the shared
-- spec against the LIVE dylib. Includes a v2 custom importer (check 5) whose
-- two callbacks resolve `@use` URLs against an in-memory file map.
--
-- Run:  luajit test.lua    (from ffi/examples/luajit/; the dylib path is
--       derived relative to this script, with a SASSO_DYLIB env override)

local ffi = require("ffi")

-- The relevant declarations from sasso.h, transcribed for ffi.cdef. Enum-ish
-- #defines become plain Lua constants below (cdef has no #define).
ffi.cdef[[
typedef struct SassoCanonicalizeContext {
  int32_t from_import;
  const char *containing_url;
} SassoCanonicalizeContext;

typedef struct SassoImporterSink SassoImporterSink;

typedef int32_t (*canonicalize_fn_t)(void *user_data, const char *url,
                                     const SassoCanonicalizeContext *ctx,
                                     SassoImporterSink *sink);
typedef int32_t (*load_fn_t)(void *user_data, const char *canonical,
                             SassoImporterSink *sink);

typedef struct SassoImporter {
  void *user_data;
  canonicalize_fn_t canonicalize;
  load_fn_t load;
} SassoImporter;

typedef struct SassoOptions {
  uint32_t struct_size;
  int32_t style;
  int32_t syntax;
  int32_t unicode;
  const char *url;
  const char *const *load_paths;
  size_t load_paths_len;
  const SassoImporter *importer;
} SassoOptions;

typedef struct SassoResult {
  int32_t ok;
  char *css;
  size_t css_len;
  char *error;
  size_t error_len;
  uint32_t error_line;
  uint32_t error_column;
} SassoResult;

const char *sasso_version(void);
void sasso_options_init(SassoOptions *options, size_t struct_size);
SassoResult *sasso_compile(const char *source, size_t source_len,
                           const SassoOptions *options);
void sasso_result_free(SassoResult *result);
void sasso_importer_set_canonical(SassoImporterSink *sink, const char *ptr, size_t len);
void sasso_importer_set_result(SassoImporterSink *sink,
                               const char *contents, size_t contents_len,
                               int32_t syntax,
                               const char *source_map_url, size_t source_map_url_len);
void sasso_importer_set_error(SassoImporterSink *sink, const char *ptr, size_t len);
]]

-- Locate the prebuilt dylib relative to this script (arg[0] is the script path),
-- honoring an explicit SASSO_DYLIB override and falling back to a .so on Linux.
local function find_dylib()
  local override = os.getenv("SASSO_DYLIB")
  if override and #override > 0 then return override end
  local dir = arg[0]:match("(.*/)") or "./"
  local base = dir .. "../../target/release/libsasso"
  for _, ext in ipairs({ ".dylib", ".so" }) do
    local path = base .. ext
    local f = io.open(path, "rb")
    if f then
      f:close()
      return path
    end
  end
  return base .. ".dylib" -- best effort; let ffi.load surface the error
end

local C = ffi.load(find_dylib())

-- Constants (from the #defines in sasso.h).
local SASSO_STYLE_EXPANDED   = 0
local SASSO_STYLE_COMPRESSED = 1
local SASSO_SYNTAX_SCSS      = 0
local SASSO_IMPORTER_OK         = 1
local SASSO_IMPORTER_NOT_FOUND  = 0
local SASSO_IMPORTER_ERROR      = -1

-- ---- test bookkeeping --------------------------------------------------
local failed = false
local function check(name, cond, detail)
  print(string.format("  %s %s%s",
    cond and "PASS" or "FAIL",
    name,
    (not cond and detail) and ("  -- " .. tostring(detail)) or ""))
  if not cond then failed = true end
end

-- ---- helpers -----------------------------------------------------------
-- Compile `src` with the given options struct (or nil for defaults).
-- Returns ok(bool), css(string|nil), error(string|nil), line, column.
local function compile(src, opts)
  local res = C.sasso_compile(src, #src, opts)
  if res == nil then return false, nil, "sasso_compile returned NULL", 0, 0 end
  local ok = res.ok ~= 0
  local css, err
  if res.css ~= nil then css = ffi.string(res.css, res.css_len) end
  if res.error ~= nil then err = ffi.string(res.error, res.error_len) end
  local line, col = res.error_line, res.error_column
  C.sasso_result_free(res) -- always free; css/err already copied into Lua strings
  return ok, css, err, line, col
end

-- ---- check 1: version --------------------------------------------------
local version = ffi.string(C.sasso_version())
check("1 sasso_version() looks like a version", version:match("^%d+%.%d+%.%d+") ~= nil, "got " .. version)

-- ---- check 2: default compile (NULL opts) ------------------------------
do
  local src = ".a { color: red; &:hover { color: blue; } }"
  local want = ".a {\n  color: red;\n}\n.a:hover {\n  color: blue;\n}"
  local ok, css = compile(src, nil)
  check("2 default compile + nesting", ok and css == want, ok and string.format("%q", css) or "compile failed")
end

-- ---- check 3: compressed compile ---------------------------------------
do
  local opts = ffi.new("SassoOptions")
  C.sasso_options_init(opts, ffi.sizeof("SassoOptions"))
  opts.style = SASSO_STYLE_COMPRESSED
  local src = ".a { color: #336699; }"
  local want = ".a{color:#369}"
  local ok, css = compile(src, opts)
  check("3 compressed + hex shorten", ok and css == want, ok and string.format("%q", css) or "compile failed")
end

-- ---- check 4: error path -----------------------------------------------
do
  local ok, css, err, line = compile(".a { color: ", nil)
  local good = (not ok) and err ~= nil and #err > 0 and line >= 1
  check("4 error path (ok==0, error, line>=1)", good, string.format("ok=%s err=%s line=%s", tostring(ok), tostring(err), tostring(line)))
  if err then
    local first = err:match("([^\n]*)") or err
    print("    first error line: " .. first)
  end
end

-- ---- check 5: v2 custom importer ---------------------------------------
do
  -- In-memory file map (canonical key -> source).
  local FILES = { ["/sub/_mod"] = "$c: #336699;\n" }

  -- /a/b -> /a   ;   / -> /
  local function dirname(p)
    local i = p:match(".*()/")    -- index of the last '/'
    if not i or i <= 1 then return "/" end
    return p:sub(1, i - 1)
  end
  -- /sub/mod -> /sub/_mod  (dart's partial spelling)
  local function as_partial(p)
    local i = p:match(".*()/") or 0
    return p:sub(1, i) .. "_" .. p:sub(i + 1)
  end

  local function resolve(url, containing)
    local base = containing and dirname(containing) or ""
    base = base:gsub("/+$", "")          -- rstrip '/'
    local joined = base .. "/" .. url
    for _, cand in ipairs({ joined, as_partial(joined) }) do
      if FILES[cand] then return cand end
    end
    return nil
  end

  -- The two C callbacks. Keep the cast objects referenced (see `keep` below)
  -- so the JIT/GC doesn't collect the trampolines while sasso holds them.
  local canonicalize = ffi.cast("canonicalize_fn_t", function(_ud, url, ctx, sink)
    local u = ffi.string(url)
    local containing = nil
    if ctx ~= nil and ctx.containing_url ~= nil then
      containing = ffi.string(ctx.containing_url)
    end
    local canon = resolve(u, containing)
    if not canon then return SASSO_IMPORTER_NOT_FOUND end
    C.sasso_importer_set_canonical(sink, canon, #canon)
    return SASSO_IMPORTER_OK
  end)

  local load = ffi.cast("load_fn_t", function(_ud, canonical, sink)
    local src = FILES[ffi.string(canonical)]
    if not src then return SASSO_IMPORTER_NOT_FOUND end
    C.sasso_importer_set_result(sink, src, #src, SASSO_SYNTAX_SCSS, nil, 0)
    return SASSO_IMPORTER_OK
  end)

  local importer = ffi.new("SassoImporter")
  importer.user_data = nil
  importer.canonicalize = canonicalize
  importer.load = load

  local opts = ffi.new("SassoOptions")
  C.sasso_options_init(opts, ffi.sizeof("SassoOptions"))
  opts.url = "/entry"
  opts.importer = importer

  -- Hold references to everything that must outlive the compile call.
  local keep = { canonicalize, load, importer, opts }

  local src = '@use "sub/mod" as m;\n.out { color: m.$c; }\n'
  local want = ".out {\n  color: #336699;\n}"
  local ok, css, err = compile(src, opts)
  check("5 v2 custom importer (relative @use)", ok and css == want,
    ok and string.format("%q", css) or ("compile failed: " .. tostring(err)))

  -- explicitly keep `keep` alive until here
  if #keep ~= 4 then error("unreachable") end
  -- free the cast callbacks now that the compile is done
  canonicalize:free()
  load:free()
end

print("RESULT: " .. (failed and "FAIL" or "PASS"))
os.exit(failed and 1 or 0)
