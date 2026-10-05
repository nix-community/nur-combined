"""Flat-field a raw CanoScan 8400F scan from scan-raw-8400f into a linear 16-bit TIFF.

corrected = (raw - dark(x)) / white(x, y), where white(x, y) = S(x, y) * P(x) comes from a
reference file (S: smooth 2D map of lamp and optics on a 5 mm grid, P: per-column sensitivity),
built from white-paper scans taken with the same dpi, line period, gain and offset.

Optionally each row is then scaled so a white strip lying on the glass at a fixed x range reads
1.0, which removes the brightness drift along the scan. The output maps 1.0 (the reference
paper's white) to --white counts.
"""

import argparse
import json
import os
import struct
import sys

import numpy as np

# driver geometry for the 8400F flatbed (backend/genesys/tables_model.cpp)
X_OFFSET_MM = 5.5
Y_OFFSET_MM = 17.0
# usable glass, in reference coordinates (mm from the head's home / from the left of the scan
# area); outside it the reference has no paper (calibration strip, frame, the lamp's dim ends)
GLASS_Y_MM = (16.0, 309.0)
GLASS_X_MM = (5.0, 215.0)
CHUNK_ROWS = 256


def load_ppm16(path):
    with open(path, "rb") as f:
        head = f.read(512)
    fields = []
    pos = 0
    while len(fields) < 4:
        while head[pos:pos + 1].isspace():
            pos += 1
        if head[pos:pos + 1] == b"#":
            pos = head.index(b"\n", pos)
            continue
        end = pos
        while not head[end:end + 1].isspace():
            end += 1
        fields.append(head[pos:end])
        pos = end
    pos += 1
    if fields[0] != b"P6" or int(fields[3]) != 65535:
        sys.exit(f"{path}: expected a 16-bit colour PPM from scan-raw-8400f")
    w, h = int(fields[1]), int(fields[2])
    return np.memmap(path, dtype=">u2", mode="r", offset=pos, shape=(h, w, 3))


def settings_of(meta):
    return {k: meta[k] for k in ("dpi", "lperiod", "gain_rgb", "offset_rgb")}


def scan_geometry(meta, dpi):
    """Column offset into reference columns, and y (mm from the head's home) of row 0's top edge.

    Reference scans are taken with --strip at left=0, top=0.
    """
    area = meta["area_mm"]
    col0 = int((X_OFFSET_MM + area["left"]) * dpi / 25.4) - int(X_OFFSET_MM * dpi / 25.4)
    y0 = (0.0 if meta.get("strip") else Y_OFFSET_MM) + area["top"]
    return col0, y0


def interp_s(S, x_c, y_c, xs_mm, ys_mm):
    """Bilinear interpolation of the (ny, nx, 3) grid S at x positions xs_mm and y positions ys_mm."""
    xi = np.clip(np.interp(xs_mm, x_c, np.arange(len(x_c))), 0, len(x_c) - 1)
    yi = np.clip(np.interp(ys_mm, y_c, np.arange(len(y_c))), 0, len(y_c) - 1)
    x0 = np.floor(xi).astype(int)
    x1 = np.minimum(x0 + 1, len(x_c) - 1)
    fx = (xi - x0)[None, :, None]
    y0 = np.floor(yi).astype(int)
    y1 = np.minimum(y0 + 1, len(y_c) - 1)
    fy = (yi - y0)[:, None, None]
    top = S[y0][:, x0] * (1 - fx) + S[y0][:, x1] * fx
    bot = S[y1][:, x0] * (1 - fx) + S[y1][:, x1] * fx
    return (top * (1 - fy) + bot * fy).astype(np.float32)


class TiffWriter:
    """Minimal baseline TIFF: little-endian, uncompressed, one strip of 16-bit RGB."""

    def __init__(self, path, width, height, dpi):
        self.w, self.h, self.dpi = width, height, dpi
        self.size = width * height * 6
        if self.size + 1024 >= 2**32:
            sys.exit("output is too large for a classic TIFF (4 GiB); scan a smaller area")
        self.ifd = 8 + self.size + (self.size & 1)
        self.f = open(path, "wb")
        self.f.write(b"II*\0" + struct.pack("<I", self.ifd))

    def write_rows(self, rows):
        self.f.write(np.ascontiguousarray(rows, dtype="<u2").tobytes())

    def close(self):
        if self.size & 1:
            self.f.write(b"\0")
        n = 13
        extra = self.ifd + 2 + n * 12 + 4
        bps, xres, yres = extra, extra + 6, extra + 14
        entries = [
            (256, 4, 1, self.w), (257, 4, 1, self.h), (258, 3, 3, bps), (259, 3, 1, 1),
            (262, 3, 1, 2), (273, 4, 1, 8), (277, 3, 1, 3), (278, 4, 1, self.h),
            (279, 4, 1, self.size), (282, 5, 1, xres), (283, 5, 1, yres), (284, 3, 1, 1),
            (296, 3, 1, 2),
        ]
        assert len(entries) == n
        out = struct.pack("<H", n)
        for tag, typ, count, value in entries:
            val = struct.pack("<HH", value, 0) if typ == 3 and count == 1 else struct.pack("<I", value)
            out += struct.pack("<HHI", tag, typ, count) + val
        out += struct.pack("<I", 0)
        out += struct.pack("<HHH", 16, 16, 16) + struct.pack("<II", self.dpi, 1) * 2
        self.f.write(out)
        self.f.close()


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("scan", help="scan prefix (PREFIX.ppm and PREFIX.json from scan-raw-8400f)")
    ap.add_argument("output", help="output TIFF path")
    ap.add_argument("--ref", required=True, help="reference .npz for this dpi and these settings")
    ap.add_argument("--dark", metavar="PREFIX",
                    help="dark frame (scan-raw-8400f --dark at the same settings) to use instead "
                    "of the reference's; the black level drifts, so use one from the same session")
    ap.add_argument("--side-strip", metavar="X0-X1",
                    help="x range in mm (as scan-raw-8400f -l counts it) of a white strip on the "
                    "glass; each row is scaled so the strip reads --strip-white")
    ap.add_argument("--side-strip-y", metavar="Y0-Y1",
                    help="y range in mm from the head's home (the white calibration strip is at "
                    "0-4 mm, the glass about 16-309 mm) that the side strip covers; rows outside "
                    "it reuse the nearest covered row's level (default: the whole glass)")
    ap.add_argument("--strip-white", type=float, default=1.0,
                    help="the side strip's whiteness relative to the reference paper (default 1.0)")
    ap.add_argument("--strip-smooth", type=float, default=5.0, metavar="MM",
                    help="average the side strip over this many mm along y (default 5)")
    ap.add_argument("--white", type=float, default=50000,
                    help="output value for the reference paper's white (default 50000)")
    ap.add_argument("--force", action="store_true",
                    help="use the reference even if its settings differ from the scan's")
    args = ap.parse_args()

    meta = json.load(open(args.scan + ".json"))
    if meta.get("dark"):
        sys.exit(f"{args.scan} is a dark frame")
    ref = np.load(args.ref)
    ref_settings = json.loads(str(ref["settings"]))
    if settings_of(meta) != ref_settings:
        msg = f"settings differ: scan {settings_of(meta)}, reference {ref_settings}"
        if not args.force:
            sys.exit(msg + " (use --force to apply anyway)")
        print("warning: " + msg, file=sys.stderr)
    dpi = int(ref["dpi"])

    img = load_ppm16(args.scan + ".ppm")
    h, w, _ = img.shape
    col0, y0 = scan_geometry(meta, dpi)
    ref_w = ref["P"].shape[0]
    if col0 < 0 or col0 + w > ref_w:
        sys.exit(f"scan columns {col0}..{col0 + w} fall outside the reference's 0..{ref_w}")
    cols = slice(col0, col0 + w)
    xs_mm = (np.arange(col0, col0 + w) + 0.5) / dpi * 25.4
    ys_mm = y0 + (np.arange(h) + 0.5) / dpi * 25.4
    if min(ys_mm[-1], GLASS_Y_MM[1]) > ref["y_c"][-1] + 2.5:
        print(f"warning: scan extends to {ys_mm[-1]:.0f} mm, the reference only to "
              f"{ref['y_c'][-1] + 2.5:.0f} mm; the last row of the reference is reused", file=sys.stderr)

    if args.dark:
        dmeta = json.load(open(args.dark + ".json"))
        if not dmeta.get("dark"):
            sys.exit(f"{args.dark} is not a dark frame")
        if settings_of(dmeta) != ref_settings and not args.force:
            sys.exit(f"dark frame settings {settings_of(dmeta)} differ from the reference's")
        dimg = load_ppm16(args.dark + ".ppm")
        dcol0, _ = scan_geometry(dmeta, dpi)
        D = np.full((ref_w, 3), np.nan, np.float32)
        D[dcol0:dcol0 + dimg.shape[1]] = dimg[::4].astype(np.float32).mean(axis=0)
        D = D[cols]
        if np.isnan(D).any():
            sys.exit("the dark frame doesn't cover all of the scan's columns")
    else:
        D = ref["D"][cols].astype(np.float32)
    P = ref["P"][cols].astype(np.float32)
    S, x_c, y_c = ref["S"], ref["x_c"], ref["y_c"]

    def corrected(r0, r1, sel=slice(None)):
        raw = img[r0:r1, sel].astype(np.float32)
        Sw = interp_s(S, x_c, y_c, xs_mm[sel], ys_mm[r0:r1])
        return (raw - D[sel]) / (Sw * P[sel])

    rowscale = np.ones((h, 3), np.float32)
    strip_info = None
    if args.side_strip:
        a, b = (float(v) for v in args.side_strip.split("-"))
        # xs_mm is in scan-raw-8400f's -l coordinates, the same as the reference's columns
        sel = np.where((xs_mm >= a) & (xs_mm < b))[0]
        if len(sel) < 3:
            sys.exit(f"side strip {a}-{b} mm isn't within the scan's columns")
        sel = slice(sel[0], sel[-1] + 1)
        level = np.concatenate([corrected(r0, min(h, r0 + CHUNK_ROWS), sel).mean(axis=1)
                                for r0 in range(0, h, CHUNK_ROWS)])
        # only rows where the strip lies on the glass see it; other rows reuse the nearest such row's level
        y_lo, y_hi = GLASS_Y_MM
        if args.side_strip_y:
            sy0, sy1 = (float(v) for v in args.side_strip_y.split("-"))
            y_lo, y_hi = max(y_lo, sy0), min(y_hi, sy1)
        on = np.where((ys_mm >= y_lo) & (ys_mm <= y_hi))[0]
        if len(on) == 0:
            sys.exit(f"the scan has no rows where the side strip lies on the glass ({y_lo:.0f}-{y_hi:.0f} mm)")
        level = level[on[0]:on[-1] + 1]
        k = max(1, int(round(args.strip_smooth / 25.4 * dpi)))
        pad = np.pad(level, ((k // 2, k - 1 - k // 2), (0, 0)), mode="edge")
        csum = np.cumsum(np.vstack([np.zeros((1, 3)), pad]), axis=0)
        smooth = (csum[k:] - csum[:-k]) / k
        smooth = np.pad(smooth, ((on[0], h - 1 - on[-1]), (0, 0)), mode="edge")
        rowscale = (smooth / args.strip_white).astype(np.float32)
        strip_info = {"x_mm": [a, b], "y_mm": [round(float(y_lo), 1), round(float(y_hi), 1)], "level_min": smooth.min(axis=0).round(4).tolist(),
                      "level_max": smooth.max(axis=0).round(4).tolist()}
        print(f"side strip {a}-{b} mm: corrected level per row R/G/B ranges "
              f"{strip_info['level_min']} .. {strip_info['level_max']}")

    out = TiffWriter(args.output, w, h, dpi)
    clipped_lo = clipped_hi = 0
    glass_x = (xs_mm >= GLASS_X_MM[0]) & (xs_mm <= GLASS_X_MM[1])
    for r0 in range(0, h, CHUNK_ROWS):
        r1 = min(h, r0 + CHUNK_ROWS)
        v = corrected(r0, r1) / rowscale[r0:r1, None, :] * args.white
        rows = (ys_mm[r0:r1] >= GLASS_Y_MM[0]) & (ys_mm[r0:r1] <= GLASS_Y_MM[1])
        on_glass = v[rows][:, glass_x]
        clipped_lo += int((on_glass < 0).sum())
        clipped_hi += int((on_glass > 65535).sum())
        out.write_rows(np.clip(np.rint(v), 0, 65535).astype(np.uint16))
    out.close()

    info = {"scan": os.path.abspath(args.scan), "ref": os.path.abspath(args.ref),
            "dark": os.path.abspath(args.dark) if args.dark else "reference", "white": args.white,
            "side_strip": strip_info, "clipped_low_on_glass": clipped_lo, "clipped_high_on_glass": clipped_hi,
            "settings": ref_settings, "size_px": [w, h]}
    with open(os.path.splitext(args.output)[0] + ".json", "w") as f:
        json.dump(info, f, indent=2)
        f.write("\n")
    print(f"{args.output}: {w}x{h} px, white = {args.white:.0f}; on the glass, "
          f"{clipped_lo} samples clipped at 0 and {clipped_hi} at 65535")


if __name__ == "__main__":
    main()
