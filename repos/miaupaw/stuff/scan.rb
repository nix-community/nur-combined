#!/usr/bin/env ruby
# frozen_string_literal: true
#
# ie-r screen-mosaic: ANSI half-block (▀) picture of the screen via --stdin.
# Each terminal cell = 2 pixel rows: fg=top, bg=bottom → ~1:1 visual aspect.
#
# Layout is discovered via `ie-r --monitors`; --monitor flag picks the slice:
#   --monitor all   (default) bounding box of all monitors; dead zones
#                   (where a shorter monitor leaves gaps) render as black.
#   --monitor N     a single monitor (index from --monitors)
#
# Run:
#   ruby stuff/scan.rb                              # all, width 150
#   ruby stuff/scan.rb --monitor 0                  # first monitor only
#   ruby stuff/scan.rb --monitor 1 --width 200      # second monitor only
#   ruby stuff/scan.rb --width 300 --lines 80       # manual aspect
#
# Binary: $IER_BIN or ./target/debug/ie-r

require 'open3'

opts = { width: 150, lines: nil, monitor: 'all' }
i = 0
while i < ARGV.size
  case ARGV[i]
  when '--width'   then opts[:width]   = Integer(ARGV[i + 1]); i += 2
  when '--lines'   then opts[:lines]   = Integer(ARGV[i + 1]); i += 2
  when '--monitor' then opts[:monitor] = ARGV[i + 1];          i += 2
  else
    warn "unknown option: #{ARGV[i]}"; exit 2
  end
end

bin = ENV['IER_BIN'] || './target/debug/ie-r'

# ── 1. Discover canvas layout via `ie-r --monitors` ───────────────────
mon_out, mon_err, mon_status = Open3.capture3(bin, '--monitors')
unless mon_status.success?
  warn "ie-r --monitors failed:\n#{mon_err}"
  exit(mon_status.exitstatus || 1)
end

monitors = mon_out.each_line.filter_map do |l|
  parts = l.strip.split("\t")
  next if parts.size < 5
  wh = parts[2].split('x').map(&:to_i)
  xy = parts[3].split(',').map(&:to_i)
  # parts[5] = transform tag ("normal"/"90"/etc) — optional diagnostic column.
  transform = parts[5] || 'normal'
  { idx: parts[0].to_i, name: parts[1], w: wh[0], h: wh[1],
    x: xy[0], y: xy[1], scale: parts[4].to_f, transform: transform }
end

if monitors.empty?
  warn 'no monitors reported by ie-r --monitors'
  exit 1
end

# ── 2. Resolve selection ──────────────────────────────────────────────
selected =
  case opts[:monitor]
  when 'all'
    monitors
  else
    idx = Integer(opts[:monitor]) rescue nil
    unless idx && idx >= 0 && idx < monitors.size
      warn "invalid --monitor #{opts[:monitor].inspect}; available: 0..#{monitors.size - 1} or 'all'"
      exit 2
    end
    [monitors[idx]]
  end

# Global min_origin (matches ie-r's min_origin shift on --pixel/--stdin input).
global_min_x = monitors.map { |m| m[:x] }.min
global_min_y = monitors.map { |m| m[:y] }.min

# Bounding box of selection in LOGICAL coords, then translated to
# desktop-relative (what --stdin consumes after min_origin shift).
sel_min_x = selected.map { |m| m[:x] }.min
sel_min_y = selected.map { |m| m[:y] }.min
sel_max_x = selected.map { |m| m[:x] + m[:w] }.max
sel_max_y = selected.map { |m| m[:y] + m[:h] }.max

scan_x_start = sel_min_x - global_min_x
scan_y_start = sel_min_y - global_min_y
scan_w       = sel_max_x - sel_min_x
scan_h       = sel_max_y - sel_min_y

cols = opts[:width]
# Auto-aspect when --lines is omitted: 1 char cell ≈ 2 half-blocks → ~1:1
# visual (cols * scan_h / scan_w gives pixel rows; ÷ 2 = half-block term lines).
lines = opts[:lines] || [(cols * scan_h.to_f / scan_w / 2).round, 1].max
rows  = lines * 2

# ── 3. Generate coord grid (desktop-relative, resilient to OOB) ───────
coords = String.new(capacity: cols * rows * 14)
rows.times do |r|
  y = scan_y_start + (r * (scan_h - 1).to_f / [rows - 1, 1].max).round
  cols.times do |c|
    x = scan_x_start + (c * (scan_w - 1).to_f / [cols - 1, 1].max).round
    coords << x.to_s << ',' << y.to_s << "\n"
  end
end

# ── 4. Sample via --stdin --with-coords (X,Y\tHEX for safe correlation) ─
# --average kernel matches the decimation step in PHYSICAL pixels so each
# terminal block reflects the mean colour of its source tile (no aliasing
# of fine detail like text edges into a random pixel pick).
# scan_w/scan_h come from `--monitors` in LOGICAL units; ie-r's --avg N
# counts PHYSICAL pixels, so we multiply the per-cell logical step by the
# tile scale. Multi-monitor selection: pick the max scale across selected
# monitors so high-DPI tiles still get a box covering their full step
# (lower-DPI tiles over-sample slightly — visually safe).
step_x = scan_w.to_f / cols
step_y = scan_h.to_f / rows
scale  = selected.map { |m| m[:scale] }.max
avg_n  = [((step_x + step_y) / 2 * scale).round, 1].max
t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
out, err, status = Open3.capture3(bin, '--stdin', '--with-coords', '--average', avg_n.to_s, '-f', 'hex', stdin_data: coords)
ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0) * 1000).round
unless status.success?
  warn err
  exit(status.exitstatus || 1)
end

# (x,y) → hex map. Anything missing (OOB on dead zones) → black fallback.
sampled = {}
out.each_line do |l|
  m = l.strip.match(/\A(\d+),(\d+)\t0x([0-9A-Fa-f]{6})\z/)
  next unless m
  sampled[[m[1].to_i, m[2].to_i]] = m[3]
end

# ── 5. Render: half-block grid; missing cells = #000000 ────────────────
want = cols * rows
got  = sampled.size
buf = String.new(capacity: cols * lines * 40)
lines.times do |li|
  cols.times do |c|
    x = scan_x_start + (c * (scan_w - 1).to_f / [cols - 1, 1].max).round
    yt = scan_y_start + ((li * 2) * (scan_h - 1).to_f / [rows - 1, 1].max).round
    yb = scan_y_start + ((li * 2 + 1) * (scan_h - 1).to_f / [rows - 1, 1].max).round
    th = sampled[[x, yt]] || '000000'
    bh = sampled[[x, yb]] || '000000'
    tr = th[0, 2].to_i(16); tg = th[2, 2].to_i(16); tb = th[4, 2].to_i(16)
    br = bh[0, 2].to_i(16); bg = bh[2, 2].to_i(16); bb = bh[4, 2].to_i(16)
    buf << "\e[38;2;#{tr};#{tg};#{tb};48;2;#{br};#{bg};#{bb}m▀"
  end
  buf << "\e[0m\n"
end
print buf

# ── 6. Diagnostic footer ──────────────────────────────────────────────
sel_label =
  if opts[:monitor] == 'all'
    rotated = monitors.count { |m| m[:transform] != 'normal' }
    suffix  = rotated.zero? ? '' : ", #{rotated} rotated"
    "all (#{monitors.size} mons#{suffix})"
  else
    s = selected[0]
    rot = s[:transform] == 'normal' ? '' : " [#{s[:transform]}]"
    "##{s[:idx]} #{s[:name]}#{rot}"
  end
oob = want - got
oob_note = oob.zero? ? '' : ", #{oob} OOB (dead zones)"
puts "\e[2m#{cols}×#{rows} samples (half-block, #{lines} term lines), " \
     "monitor: #{sel_label}, scan #{scan_w}×#{scan_h} px, " \
     "avg=#{avg_n}px, got #{got}/#{want}#{oob_note}, snapshot in #{ms} ms\e[0m"
