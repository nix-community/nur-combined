#!/usr/bin/env ruby
# frozen_string_literal: true
#
# ie-r CLI contract probe.
# Exercises the headless surface through pipes, verifying stdout format
# and exit codes against the documented CLI contract.
#
# Run:    ruby stuff/probe.rb     (or ./stuff/probe.rb after chmod +x)
# Binary: $IER_BIN or ./target/debug/ie-r

require 'open3'

BIN = ENV['IER_BIN'] || './target/debug/ie-r'
HEX       = /\A0x[0-9A-Fa-f]{6}\z/.freeze
HTML      = /\A#[0-9A-Fa-f]{6}\z/.freeze
# Absolute coords may be negative (monitor left of / above the origin).
SELF_CORR = /\A-?\d+,-?\d+\t.+\z/.freeze

def run(args, stdin: '')
  out, err, status = Open3.capture3(BIN, *args, stdin_data: stdin)
  [out, err, status.exitstatus]
end

# ── Layout discovery ───────────────────────────────────────────────────
# Logical coords are ABSOLUTE compositor space (2026-08-09 contract), so
# the suite derives an in-bounds base from --monitors instead of assuming
# the layout starts at 0,0 — offset origins are exactly the configurations
# the contract was fixed on, and this probe must pass there too.
mon_out, mon_err, mon_ec = run(%w[--monitors])
first_row = mon_out.lines.reject { |l| l.start_with?('#') }.first
abort "cannot discover layout via --monitors: #{mon_err}" unless mon_ec&.zero? && first_row
BX, BY = first_row.split("\t")[3].split(',').map(&:to_i)

# Absolute logical coord at offset (dx, dy) from the first monitor's corner.
def at(dx, dy) = "#{BX + dx},#{BY + dy}"

@pass = 0
@fail = 0
def ok(name, cond, hint = nil)
  if cond
    @pass += 1
    puts "  \e[32m✓\e[0m #{name}"
  else
    @fail += 1
    puts "  \e[31m✗\e[0m #{name}#{hint ? "  — #{hint}" : ''}"
  end
end

def section(label) = puts("\e[1m#{label}\e[0m")

# ── --pixel ────────────────────────────────────────────────────────────
section '--pixel'
out, _e, ec = run(['--pixel', at(0, 0), '-f', 'hex'])
ok 'base coord hex → exit 0 + hex value', ec.zero? && out.strip =~ HEX, "ec=#{ec} out=#{out.inspect}"

_o, err, ec = run(%w[--pixel 99999,99999])
ok 'oob → exit 2 + stderr message', ec == 2 && err.include?('out of bounds'), "ec=#{ec}"

_o, _e, ec = run(%w[--pixel abc])
ok 'bad coord → exit 2', ec == 2, "ec=#{ec}"

# ── verbosity ──────────────────────────────────────────────────────────
section 'verbosity'
_o, err, ec = run(['--pixel', at(0, 0), '-f', 'hex'])
ok 'non-daemon default → stderr silent (no Capture/INFO leak)',
   ec.zero? && !err.include?('Capture'), "err=#{err.inspect}"

_o, err, ec = run(['--pixel', at(0, 0), '-f', 'hex', '-v'])
ok '-v → INFO-tier visible (Capture log present)',
   ec.zero? && err.include?('Capture'), "err=#{err.inspect}"

# ── relay axis ─────────────────────────────────────────────────────────
section 'relay axis'
out, err, ec = run(['--pixel', at(10, 10), '-f', 'hex'])
ok 'default = stdout only, no swatch in stderr',
   ec.zero? && out.lines.count == 1 && !err.include?('██'),
   "out=#{out.inspect} err=#{err.inspect}"

_o, err, ec = run(['--pixel', at(10, 10), '-f', 'hex', '-s'])
ok '--swatch (-s) → swatch in stderr', ec.zero? && err.include?('██'), "err=#{err.inspect}"

out, _e, ec = run(['--pixel', at(10, 10), '-q', '-c'])
ok '-q -c → silent stdout, clipboard relay', ec.zero? && out.empty?, "out=#{out.inspect}"

# ── --pixels (atomic batch) ────────────────────────────────────────────
section '--pixels (atomic batch)'
out, _e, ec = run(['--pixels', "#{at(0, 0)};#{at(100, 100)};#{at(50, 50)}", '-f', 'hex'])
ok 'three ok coords → 3 lines, all hex, in order',
   ec.zero? && out.lines.count == 3 && out.lines.all? { |l| l.strip =~ HEX },
   "out=#{out.inspect}"

out, err, ec = run(['--pixels', "#{at(0, 0)};99999,99999;#{at(50, 50)}", '-f', 'hex'])
ok 'one oob → exit 2, ZERO partial stdout',
   ec == 2 && out.empty? && err.include?('out of bounds'),
   "ec=#{ec} out=#{out.inspect}"

# ── --stdin (resilient; bare default, --with-coords opt-in) ────────────
# --stdin default is bare VALUE per line (symmetric with --pick).
# Self-correlating X,Y\tVALUE is opt-in via --with-coords.
section '--stdin (resilient stream)'
out, _e, ec = run(%w[--stdin -f hex], stdin: "#{at(10, 10)}\n#{at(20, 20)}\n")
ok 'two ok lines → 2 bare VALUE lines (no X,Y prefix), exit 0',
   ec.zero? && out.lines.count == 2 && out.lines.all? { |l| l.strip =~ HEX },
   "out=#{out.inspect}"

out, _e, ec = run(%w[--stdin --with-coords -f hex], stdin: "#{at(10, 10)}\n#{at(20, 20)}\n")
ok '--with-coords → self-correlating X,Y\\tVALUE per line, exit 0',
   ec.zero? && out.lines.count == 2 && out.lines.all? { |l| l.strip =~ SELF_CORR },
   "out=#{out.inspect}"

out, err, ec = run(%w[--stdin -f hex], stdin: "#{at(10, 10)}\nbadline\n#{at(20, 20)}\n")
ok 'bad line in middle → skip+warn, 2 ok lines, exit 0',
   ec.zero? && out.lines.count == 2 && err.include?('skipped'),
   "ec=#{ec} out=#{out.inspect}"

out, _e, ec = run(%w[--stdin -c -f hex], stdin: "#{at(0, 0)}\n#{at(1, 1)}\n")
ok '--stdin -c → exit 0 (snapshot: join+set once, like --pixels -c)',
   ec.zero? && out.lines.count == 2, "ec=#{ec} out=#{out.inspect}"

_o, err, ec = run(%w[--stdin --rt --clipboard], stdin: "#{at(0, 0)}\n")
ok '--stdin --rt -c → exit 2 (realtime: per-line clipboard = thrash)',
   ec == 2 && err.include?('not supported'), "ec=#{ec}"

out, _e, ec = run(%w[--stdin --rt -f hex], stdin: "#{at(10, 10)}\n#{at(20, 20)}\n")
ok '--stdin --rt → live mode, 2 bare lines, exit 0',
   ec.zero? && out.lines.count == 2 && out.lines.all? { |l| l.strip =~ HEX },
   "out=#{out.inspect}"

# ── --history (read disk) ──────────────────────────────────────────────
# `--history` is an acquisition mode (reads the on-disk history file).
# The write side is the explicit `--write-history` relay (symmetric with
# the [pick] write_history config flag).
section '--history (read disk)'
out, _e, ec = run(%w[--history -n 1])
ok '--history -n 1 → exit 0, single line, html-shaped',
   ec.zero? && out.lines.count == 1 && out.lines.first.strip =~ HTML,
   "ec=#{ec} out=#{out.inspect}"

out, _e, ec = run(%w[--history -n 0])
ok '--history -n 0 → all stored entries (≥1 line), exit 0',
   ec.zero? && !out.lines.empty?, "out_lines=#{out.lines.count}"

# ── --config PATH validation ───────────────────────────────────────────
section '--config PATH validation'
_o, err, ec = run(%w[--config /tmp/ie-r-probe-nonexistent.toml --pixel 0,0])
ok 'missing config path → exit 2 + clear error',
   ec == 2 && err.include?('config file not found'), "ec=#{ec} err=#{err.inspect}"

# ── --monitors (canvas layout) ─────────────────────────────────────────
# `#`-prefixed self-describing header (coord space), then TSV:
# index<TAB>name<TAB>WxH<TAB>X,Y<TAB>scale<TAB>transform per monitor.
section '--monitors (canvas layout)'
out, _e, ec = run(%w[--monitors])
data_lines = out.lines.reject { |l| l.start_with?('#') }
ok '--monitors → exit 0, `# coords:` header, ≥1 TSV line, 6 tab-fields (idx/name/WxH/X,Y/scale/transform)',
   ec.zero? && out.lines.first&.start_with?('# coords: absolute logical') &&
     !data_lines.empty? && data_lines.all? { |l| l.strip.split("\t").size == 6 },
   "ec=#{ec} out=#{out.inspect}"

_o, _e, ec = run(%w[--monitors --pixel 0,0])
ok '--monitors + --pixel → exit 2 (mutex)', ec == 2

# ── --float-precision override ─────────────────────────────────────────
# Per-invocation override of config.templates.float_precision. Only
# meaningful with `-f float` (silently ignored otherwise).
section '--float-precision'
out, _e, ec = run(['--pixel', at(0, 0), '-f', 'float', '--float-precision', '3'])
ok '-f float --float-precision 3 → ~3 decimals per channel',
   ec.zero? && out.strip.split(', ').all? { |v| v =~ /\A0\.\d{1,4}\z/ || v == '0' || v == '1' },
   "out=#{out.inspect}"

out, _e, ec = run(['--pixel', at(0, 0), '-f', 'hex', '--float-precision', '5'])
ok '-f hex --float-precision 5 → silently ignored (still hex)',
   ec.zero? && out.strip =~ HEX, "out=#{out.inspect}"

# ── physical-coord input (--pixel N:X,Y) ──────────────────────────────
# Dual-mode coord axis: default `X,Y` is compositor logical (grim/slurp),
# `N:X,Y` opt-in is per-tile physical with explicit monitor index.
# Roundtrip: --pick --with-coords --phys → N:X,Y\tHEX → fed back via
# --pixel N:X,Y, the same pixel resamples to the same colour.
section 'physical-coord input (--pixel N:X,Y)'

out, _e, ec = run(%w[--pixel 0:50,50 -f hex])
ok '--pixel 0:50,50 → exit 0 + hex (monitor 0 physical)',
   ec.zero? && out.strip =~ HEX, "ec=#{ec} out=#{out.inspect}"

_o, err, ec = run(%w[--pixel 99:50,50 -f hex])
ok '--pixel 99:X,Y (bad monitor idx) → exit 2',
   ec == 2 && err.include?('out of bounds'), "ec=#{ec} err=#{err.inspect}"

_o, _e, ec = run(%w[--pixel abc:50,50 -f hex])
ok '--pixel abc:X,Y (non-numeric idx) → exit 2', ec == 2

# Negative absolute coords are legal input (monitors left of / above the
# origin: Hyprland auto-placement, Windows virtual screen). lexopt takes
# the value even though it starts with `-` — no forced quoting. Far-OOB
# on any sane layout, so the guard is: parsed as coords, failed as OOB.
_o, err, ec = run(%w[--pixel -32000,-32000 -f hex])
ok '--pixel -32000,-32000 → parsed as coords (exit 2 OOB, not an option error)',
   ec == 2 && err.include?('out of bounds') && err.include?('-32000,-32000'),
   "ec=#{ec} err=#{err.inspect}"

# Stdin can mix the two input forms in one stream — each line parsed
# independently. Emit form follows `--phys` (default = logical), not the
# per-line input form, so the output stream is uniform regardless of mix.
out, _e, ec = run(%w[--stdin -f hex --with-coords], stdin: "#{at(10, 10)}\n0:20,20\n")
ok '--stdin mixed input → default emit is logical for both lines',
   ec.zero? && out.lines.count == 2 &&
     !out.lines[0].include?(':') &&
     !out.lines[1].include?(':'),
   "out=#{out.inspect}"

# B-hybrid: `--phys` without `N:` syntax is ambiguous on multi-monitor.
# Single-mon → implicit monitor 0 (silent). Multi-mon → skip+warn per line
# in --stdin (resilient policy). This test runs on whatever the host setup
# happens to be — assert *one of* the two valid behaviours.
out, err, ec = run(%w[--stdin -f hex --with-coords --phys], stdin: "10,10\n0:20,20\n")
ok '--stdin --phys: ambiguous logical input handled per-host (skip+warn on multi-mon, resolve on single)',
   ec.zero? && (
     # multi-mon: line 1 skipped with warning, line 2 (explicit syntax) emits
     (out.lines.count == 1 && out.lines[0].match?(/\A0:\d+,\d+\t/) && err.include?('ambiguous')) ||
     # single-mon: both lines resolved to monitor 0, uniform N:X,Y emit
     (out.lines.count == 2 &&
       out.lines[0].match?(/\A0:\d+,\d+\t/) &&
       out.lines[1].match?(/\A0:\d+,\d+\t/))
   ),
   "out=#{out.inspect} err=#{err.inspect}"

# Explicit syntax + --phys: physical input + physical emit, both monitors
# unambiguous. Works on any host setup.
out, _e, ec = run(%w[--stdin -f hex --with-coords --phys], stdin: "0:10,10\n0:20,20\n")
ok '--stdin --phys + explicit N: syntax → both lines emit as 0:X,Y',
   ec.zero? && out.lines.count == 2 &&
     out.lines[0].match?(/\A0:\d+,\d+\t/) &&
     out.lines[1].match?(/\A0:\d+,\d+\t/),
   "out=#{out.inspect}"

# B-hybrid `--pixel --phys` without N: → atomic behaviour. Host-aware:
# multi-mon → exit 2 with `ambiguous` + `use N:X,Y` hint. Single-mon →
# silent resolve to monitor 0 + valid hex.
mon_out, _e, _ec = run(%w[--monitors])
mon_count = mon_out.lines.reject { |l| l.start_with?('#') }.count
out, err, ec = run(%w[--pixel 100,100 --phys -f hex])
if mon_count > 1
  ok '--pixel 100,100 --phys on multi-mon → exit 2 + ambiguity help',
     ec == 2 && err.include?('ambiguous') && err.include?('N:X,Y'),
     "ec=#{ec} err=#{err.inspect}"
else
  ok '--pixel 100,100 --phys on single-mon → exit 0 + valid hex (implicit monitor 0)',
     ec.zero? && out.strip =~ HEX, "ec=#{ec} out=#{out.inspect}"
end

# Flag order is parsing-agnostic — `--pixel` coords are deferred-parsed
# in parse_args, so `--pixel ... --phys` and `--phys --pixel ...` produce
# identical results. Swatch (stderr) carries the coord prefix for
# verification (--with-coords applies to --pick/--stdin, not --pixel).
_o, err_a, _ec = run(%w[--pixel 0:50,50 --phys -f hex -s])
_o, err_b, _ec = run(%w[--phys --pixel 0:50,50 -f hex -s])
ok '--phys flag order doesn\'t matter (deferred parsing)',
   err_a == err_b && err_a.include?('(0:50,50)'),
   "a=#{err_a.inspect} b=#{err_b.inspect}"

# ── --average / --avg N (box-filter sampling) ─────────────────────────
# N×N box-filter mean-pool around each coord. N=1 ≡ single pixel
# (no-op, the legacy fast path). --history/--monitors ignore the flag.
section '--average / --avg (box-filter sampling)'

out_a, _e, _ec = run(['--pixel', at(50, 50), '-f', 'hex'])
out_b, _e, _ec = run(['--pixel', at(50, 50), '-f', 'hex', '--avg', '1'])
ok '--avg 1 ≡ single pixel (same value as omitted)',
   out_a.strip == out_b.strip && out_a.strip =~ HEX,
   "a=#{out_a.inspect} b=#{out_b.inspect}"

out, _e, ec = run(['--pixel', at(50, 50), '-f', 'hex', '--avg', '5'])
ok '--avg 5 → exit 0 + valid hex', ec.zero? && out.strip =~ HEX, "out=#{out.inspect}"

_o, err, ec = run(%w[--pixel 0,0 --avg 0])
ok '--avg 0 → exit 2 + clear error',
   ec == 2 && err.include?('must be ≥ 1'), "ec=#{ec} err=#{err.inspect}"

out_short, _e, _ec = run(['--pixel', at(50, 50), '-f', 'hex', '--avg', '3'])
out_long,  _e, _ec = run(['--pixel', at(50, 50), '-f', 'hex', '--average', '3'])
ok '--avg and --average are aliases', out_short == out_long,
   "short=#{out_short.inspect} long=#{out_long.inspect}"

out, _e, ec = run(%w[--history -n 1 --avg 5])
ok '--history + --avg → silent noop (no sampling, no error)',
   ec.zero? && out.lines.count == 1, "ec=#{ec} out=#{out.inspect}"

# ── probe baseline = html (user-visible state vs automation contract) ──
# Probe modes deliberately IGNORE config.templates.selected (which mutates
# via tray/overlay — non-deterministic for scripts) and use a hardcoded
# "html" baseline. Explicit -f still overrides.
section 'probe baseline = html'
out, _e, ec = run(['--pixel', at(0, 0)])
ok '--pixel without -f → html (#RRGGBB), not hex/rgb/etc',
   ec.zero? && out.strip =~ HTML, "out=#{out.inspect}"

out, _e, ec = run(['--pixel', at(0, 0), '-f', 'rgb'])
ok '--pixel -f rgb → explicit override wins over baseline',
   ec.zero? && out.strip =~ /\A\d+, \d+, \d+\z/, "out=#{out.inspect}"

# ── mutual exclusion & usage errors ────────────────────────────────────
section 'mutual exclusion & usage errors'
_o, _e, ec = run(%w[--pick --pixel 1,1])
ok '--pick + --pixel → exit 2', ec == 2

_o, _e, ec = run(%w[--pick --stdin])
ok '--pick + --stdin → exit 2', ec == 2

_o, _e, ec = run(%w[--pick --history])
ok '--pick + --history → exit 2', ec == 2

_o, _e, ec = run(%w[--bogus])
ok 'unknown flag → exit 2', ec == 2

# ── summary ───────────────────────────────────────────────────────────
puts
total = @pass + @fail
if @fail.zero?
  puts "\e[1;32m#{@pass}/#{total} ok\e[0m"
  exit 0
else
  puts "\e[1;31m#{@fail} failed, #{@pass}/#{total} ok\e[0m"
  exit 1
end
