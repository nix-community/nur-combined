#!/usr/bin/env ruby
# frozen_string_literal: true
#
# sasso C ABI (FFI v2) binding for Ruby using ONLY the stdlib `Fiddle`.
# No gems, no compiler. Loads the prebuilt libsasso shared library and asserts
# the 5 spec checks, including a v2 custom importer driven by an in-memory file
# map.
#
#   ruby examples/ruby/test.rb
#
# Ownership model: a callback never hands sasso an owned pointer. It calls one
# of the sasso_importer_set_* functions with the sink; sasso copies the bytes
# immediately, and Ruby keeps ownership of its own (GC'd) buffers.

require "fiddle"

T = Fiddle # shorthand for the type constants below

# --- locate the prebuilt dylib (absolute path; dlopen-based) ------------------
HERE = File.expand_path(__dir__)
LIBPATH = [
  File.expand_path("#{HERE}/../../target/release/libsasso.dylib"),
  File.expand_path("#{HERE}/../../target/release/libsasso.so"),
].find { |p| File.exist?(p) } or abort "libsasso not found under ffi/target/release"

LIB = Fiddle.dlopen(LIBPATH)

# --- ABI constants ------------------------------------------------------------
SASSO_STYLE_EXPANDED   = 0
SASSO_STYLE_COMPRESSED = 1
SASSO_SYNTAX_SCSS      = 0
SASSO_IMPORTER_OK        = 1
SASSO_IMPORTER_NOT_FOUND = 0
SASSO_IMPORTER_ERROR     = -1

# --- function bindings --------------------------------------------------------
SASSO_VERSION = Fiddle::Function.new(LIB["sasso_version"], [], T::TYPE_VOIDP)
SASSO_COMPILE = Fiddle::Function.new(
  LIB["sasso_compile"],
  [T::TYPE_VOIDP, T::TYPE_SIZE_T, T::TYPE_VOIDP],
  T::TYPE_VOIDP,
)
SASSO_RESULT_FREE = Fiddle::Function.new(LIB["sasso_result_free"], [T::TYPE_VOIDP], T::TYPE_VOID)
SASSO_OPTIONS_INIT = Fiddle::Function.new(
  LIB["sasso_options_init"], [T::TYPE_VOIDP, T::TYPE_SIZE_T], T::TYPE_VOID
)
SASSO_SET_CANONICAL = Fiddle::Function.new(
  LIB["sasso_importer_set_canonical"], [T::TYPE_VOIDP, T::TYPE_VOIDP, T::TYPE_SIZE_T], T::TYPE_VOID
)
SASSO_SET_RESULT = Fiddle::Function.new(
  LIB["sasso_importer_set_result"],
  [T::TYPE_VOIDP, T::TYPE_VOIDP, T::TYPE_SIZE_T, T::TYPE_INT, T::TYPE_VOIDP, T::TYPE_SIZE_T],
  T::TYPE_VOID,
)
SASSO_SET_ERROR = Fiddle::Function.new(
  LIB["sasso_importer_set_error"], [T::TYPE_VOIDP, T::TYPE_VOIDP, T::TYPE_SIZE_T], T::TYPE_VOID
)

# --- #[repr(C)] field byte offsets (64-bit, natural alignment) ----------------
# SassoResult:  ok i32 @0 | css ptr @8 | css_len @16 | error ptr @24
#               | error_len @32 | line u32 @40 | col u32 @44   (size 48)
RESULT_SIZE = 48
# SassoOptions: struct_size u32 @0 | style i32 @4 | syntax i32 @8 | unicode i32 @12
#               | url ptr @16 | load_paths ptr @24 | load_paths_len @32 | importer ptr @40 (size 48)
OPTIONS_SIZE = 48
OFF_STYLE    = 4
OFF_SYNTAX   = 8
OFF_URL      = 16
OFF_IMPORTER = 40
# SassoImporter: user_data ptr @0 | canonicalize fn @8 | load fn @16   (size 24)
IMPORTER_SIZE = 24
# SassoCanonicalizeContext: from_import i32 @0 | containing_url ptr @8 (size 16)
OFF_CTX_CONTAINING = 8

# Read a (ptr, len) UTF-8 slice out of a struct at the given byte offsets.
def read_str(base, ptr_off, len_off)
  ptr = base[ptr_off, 8].unpack1("Q")
  len = base[len_off, 8].unpack1("Q")
  return +"" if ptr.zero?

  Fiddle::Pointer.new(ptr)[0, len].dup.force_encoding("UTF-8")
end

# Read a NUL-terminated C string from a raw integer address (or nil).
def read_cstr(addr)
  return nil if addr.nil? || addr.zero?

  Fiddle::Pointer.new(addr).to_s.force_encoding("UTF-8")
end

# Compile `src`; returns [ok, css_or_nil, err_or_nil, line]. opts_ptr may be nil.
def compile(src, opts_ptr = nil)
  bytes = src.dup.force_encoding("BINARY")
  res = SASSO_COMPILE.call(bytes, bytes.bytesize, opts_ptr)
  base = Fiddle::Pointer.new(res.to_i)
  begin
    ok = base[0, 4].unpack1("l")
    if ok != 0
      [true, read_str(base, 8, 16), nil, 0]
    else
      line = base[40, 4].unpack1("L")
      [false, nil, read_str(base, 24, 32), line]
    end
  ensure
    SASSO_RESULT_FREE.call(res)
  end
end

# --- in-memory importer (FFI v2) ---------------------------------------------
def dirname(p)
  i = p.rindex("/")
  i.nil? || i <= 0 ? "/" : p[0...i]
end

def as_partial(p)
  i = p.rindex("/")
  i.nil? ? "_#{p}" : "#{p[0..i]}_#{p[(i + 1)..]}"
end

# Build a SassoImporter struct over an in-memory {canonical => source} map.
# Returns [importer_ptr, keepalive]. The keepalive array MUST stay referenced
# for as long as the importer is in use, or Fiddle will GC the closures.
def make_importer(files)
  resolve = lambda do |url, containing|
    base = containing ? dirname(containing) : ""
    joined = "#{base.sub(%r{/+\z}, '')}/#{url}"
    [joined, as_partial(joined)].find { |cand| files.key?(cand) }
  end

  # int32 (*canonicalize)(void* ud, const char* url, const ctx*, sink*)
  canon_cb = Fiddle::Closure::BlockCaller.new(
    T::TYPE_INT,
    [T::TYPE_VOIDP, T::TYPE_VOIDP, T::TYPE_VOIDP, T::TYPE_VOIDP],
  ) do |_ud, url_ptr, ctx_ptr, sink|
    url = read_cstr(url_ptr.to_i)
    containing =
      if ctx_ptr.to_i.zero?
        nil
      else
        read_cstr(Fiddle::Pointer.new(ctx_ptr.to_i)[OFF_CTX_CONTAINING, 8].unpack1("Q"))
      end
    canon = resolve.call(url, containing)
    if canon.nil?
      SASSO_IMPORTER_NOT_FOUND
    else
      b = canon.dup.force_encoding("BINARY")
      SASSO_SET_CANONICAL.call(sink, b, b.bytesize)
      SASSO_IMPORTER_OK
    end
  end

  # int32 (*load)(void* ud, const char* canonical, sink*)
  load_cb = Fiddle::Closure::BlockCaller.new(
    T::TYPE_INT,
    [T::TYPE_VOIDP, T::TYPE_VOIDP, T::TYPE_VOIDP],
  ) do |_ud, canon_ptr, sink|
    src = files[read_cstr(canon_ptr.to_i)]
    if src.nil?
      SASSO_IMPORTER_NOT_FOUND
    else
      b = src.dup.force_encoding("BINARY")
      SASSO_SET_RESULT.call(sink, b, b.bytesize, SASSO_SYNTAX_SCSS, nil, 0)
      SASSO_IMPORTER_OK
    end
  end

  imp = Fiddle::Pointer.malloc(IMPORTER_SIZE)
  imp[0, 8] = [0].pack("Q")                 # user_data = NULL
  imp[8, 8] = [canon_cb.to_i].pack("Q")     # canonicalize fn ptr
  imp[16, 8] = [load_cb.to_i].pack("Q")     # load fn ptr
  [imp, [canon_cb, load_cb, imp]]
end

# Build a SassoOptions with sasso_options_init, then override fields.
# Returns [opts_ptr, keepalive].
def make_options(style: SASSO_STYLE_EXPANDED, url: nil, importer_ptr: nil)
  opts = Fiddle::Pointer.malloc(OPTIONS_SIZE)
  SASSO_OPTIONS_INIT.call(opts, OPTIONS_SIZE)
  opts[OFF_STYLE, 4] = [style].pack("l")
  opts[OFF_SYNTAX, 4] = [SASSO_SYNTAX_SCSS].pack("l")
  keep = [opts]
  if url
    url_buf = Fiddle::Pointer.to_ptr(url.dup.force_encoding("BINARY") + "\x00")
    opts[OFF_URL, 8] = [url_buf.to_i].pack("Q")
    keep << url_buf
  end
  if importer_ptr
    opts[OFF_IMPORTER, 8] = [importer_ptr.to_i].pack("Q")
    keep << importer_ptr
  end
  [opts, keep]
end

# --- test harness -------------------------------------------------------------
$failed = false
def check(name, cond, detail = "")
  status = cond ? "PASS" : "FAIL"
  line = "  [#{status}] #{name}"
  line += "  -- #{detail}" if !cond && !detail.empty?
  puts line
  $failed = true unless cond
end

puts "sasso C ABI Ruby (Fiddle) binding test"
puts "lib: #{LIBPATH}"
puts

# 1. version looks like a version
version = read_cstr(SASSO_VERSION.call.to_i)
check("1 sasso_version() looks like a version", version =~ /\A\d+\.\d+\.\d+/ ? true : false, version.inspect)

# 2. default expanded compile with nesting
ok, css, = compile(".a { color: red; &:hover { color: blue; } }")
expected2 = ".a {\n  color: red;\n}\n.a:hover {\n  color: blue;\n}"
check("2 default expanded compile", ok && css == expected2, css.inspect)

# 3. compressed compile + hex shortening
opts3, _k3 = make_options(style: SASSO_STYLE_COMPRESSED)
ok, css, = compile(".a { color: #336699; }", opts3)
check("3 compressed compile", ok && css == ".a{color:#369}", css.inspect)

# 4. error path
ok, _css, err, line = compile(".a { color: ")
check(
  "4 error path (ok==0, error set, line>=1)",
  !ok && !err.nil? && !err.empty? && line >= 1,
  "ok=#{ok} line=#{line}",
)
unless ok
  first = (err || "").each_line.first.to_s.chomp
  puts "      first error line: #{first}"
end

# 5. v2 custom importer with in-memory file map
FILES = { "/sub/_mod" => "$c: #336699;\n" }.freeze
imp_ptr, _keep_imp = make_importer(FILES)
opts5, _keep_opts = make_options(url: "/entry", importer_ptr: imp_ptr)
ok, css, err, = compile("@use \"sub/mod\" as m;\n.out { color: m.$c; }\n", opts5)
expected5 = ".out {\n  color: #336699;\n}"
check("5 v2 custom importer", ok && css == expected5, (ok ? css : err).inspect)

puts
puts "RESULT: #{$failed ? 'FAIL' : 'PASS'}"
exit($failed ? 1 : 0)
