"""Scan with the CanoScan 8400F in raw mode using explicit analog settings, then print stats.

Uses the env-var overrides from sane-genesys-8400f-no-calibration.patch: calibration and
hardware shading are off, so the output is the sensor data as digitised by the WM8199 with
the exposure/gain/offset given here. Meant for finding good values for those settings.
"""

import argparse
import json
import os
import subprocess
import sys

import numpy as np

SCANIMAGE = "@scanimage@"
RESOLUTIONS = (400, 800, 1600, 3200)
# reflective line period the driver uses by default, per resolution
DEFAULT_LPERIOD = {400: 7200, 800: 7200, 1600: 14400, 3200: 28800}


def rgb(spec, lo, hi, name):
    """Parse 'v' or 'r,g,b' into three ints within [lo, hi]."""
    parts = spec.split(",")
    if len(parts) == 1:
        parts *= 3
    if len(parts) != 3:
        raise argparse.ArgumentTypeError(f"{name}: expected one value or r,g,b")
    try:
        vals = [int(p) for p in parts]
    except ValueError:
        raise argparse.ArgumentTypeError(f"{name}: not an integer: {spec}")
    for v in vals:
        if not lo <= v <= hi:
            raise argparse.ArgumentTypeError(f"{name}: {v} not in [{lo}, {hi}]")
    return vals


def pga_gain(code):
    # WM8199 datasheet eqn. 5
    return 208 / (283 - code)


def offset_mv(code):
    # WM8199 datasheet eqn. 4
    return 260 * (code - 127.5) / 127.5


def read_ppm16(path):
    with open(path, "rb") as f:
        data = f.read()
    # P6 header: magic, width, height, maxval, each followed by whitespace
    fields = []
    pos = 0
    while len(fields) < 4:
        while data[pos:pos + 1].isspace():
            pos += 1
        if data[pos:pos + 1] == b"#":
            pos = data.index(b"\n", pos)
            continue
        end = pos
        while not data[end:end + 1].isspace():
            end += 1
        fields.append(data[pos:end])
        pos = end
    pos += 1
    magic, width, height, maxval = fields[0], int(fields[1]), int(fields[2]), int(fields[3])
    if magic != b"P6" or maxval != 65535:
        sys.exit(f"{path}: expected a 16-bit colour PPM, got {magic!r} maxval {maxval}")
    return np.frombuffer(data, dtype=">u2", offset=pos).reshape(height, width, 3)


def print_stats(img):
    pct = (0.1, 1, 50, 99, 99.9)
    print(f"{'':6}{'min':>7}{'p0.1':>7}{'p1':>7}{'median':>8}{'p99':>7}{'p99.9':>7}{'max':>7}"
          f"{'mean':>9}{'at 0':>9}{'at max':>9}{'noise':>8}{'pattern':>9}")
    for c, name in enumerate("RGB"):
        ch = img[:, :, c]
        p = np.percentile(ch, pct)
        zero = np.count_nonzero(ch == 0) / ch.size * 100
        full = np.count_nonzero(ch == 65535) / ch.size * 100
        # noise: typical line-to-line variation of one pixel (mean over columns of the
        # per-column std); pattern: how much column averages differ from each other
        noise = ch.std(axis=0).mean() if ch.shape[0] > 1 else float("nan")
        pattern = ch.mean(axis=0).std()
        print(f"{name:6}{ch.min():7d}{p[0]:7.0f}{p[1]:7.0f}{p[2]:8.0f}{p[3]:7.0f}{p[4]:7.0f}"
              f"{ch.max():7d}{ch.mean():9.1f}{zero:8.2f}%{full:8.2f}%{noise:8.1f}{pattern:9.1f}")
    print("(at 0 / at max: share of samples clipped at the bottom / top of the ADC range)")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("output", help="output file prefix; writes PREFIX.ppm and PREFIX.json")
    ap.add_argument("--dpi", type=int, choices=RESOLUTIONS, required=True)
    ap.add_argument("--lperiod", type=int, metavar="N",
                    help="line period in pixel times, 1-65535 (the shared exposure time; "
                         "driver default: 7200/7200/14400/28800 for 400/800/1600/3200 dpi)")
    ap.add_argument("--exposure", type=lambda s: rgb(s, 1, 65535, "--exposure"),
                    metavar="R,G,B", help="per-colour CCD shutter time in pixel times "
                    "(may have no effect on this scanner; default 40000 = whole line)")
    ap.add_argument("--gain", type=lambda s: rgb(s, 0, 255, "--gain"), required=True,
                    metavar="R,G,B", help="WM8199 PGA codes, 0-255 (gain = 208/(283-code))")
    ap.add_argument("--offset", type=lambda s: rgb(s, 0, 255, "--offset"), required=True,
                    metavar="R,G,B", help="WM8199 offset DAC codes, 0-255; on this scanner a "
                    "LOWER code raises the black level")
    ap.add_argument("--dark", action="store_true", help="lamp off during the scan (dark frame)")
    ap.add_argument("-l", "--left", type=float, default=0, metavar="MM")
    ap.add_argument("-t", "--top", type=float, default=0, metavar="MM")
    ap.add_argument("-x", "--width", type=float, default=215, metavar="MM")
    ap.add_argument("-y", "--height", type=float, default=10, metavar="MM")
    ap.add_argument("-d", "--device", help="SANE device name (default: first found)")
    args = ap.parse_args()

    env = dict(os.environ)
    env["SANE_GENESYS_8400F_NO_CALIBRATION"] = "1"
    env["SANE_GENESYS_8400F_AFE_GAIN"] = ",".join(map(str, args.gain))
    env["SANE_GENESYS_8400F_AFE_OFFSET"] = ",".join(map(str, args.offset))
    env.pop("SANE_GENESYS_8400F_LPERIOD", None)
    env.pop("SANE_GENESYS_8400F_EXPOSURE", None)
    if args.lperiod is not None:
        if not 1 <= args.lperiod <= 65535:
            ap.error("--lperiod must be in 1-65535")
        env["SANE_GENESYS_8400F_LPERIOD"] = str(args.lperiod)
    if args.exposure is not None:
        env["SANE_GENESYS_8400F_EXPOSURE"] = ",".join(map(str, args.exposure))

    cmd = [SCANIMAGE, "--format=pnm", "--mode=Color", "--depth=16",
           f"--resolution={args.dpi}", "--source=Flatbed",
           f"--lamp-off-scan={'yes' if args.dark else 'no'}",
           "-l", str(args.left), "-t", str(args.top),
           "-x", str(args.width), "-y", str(args.height)]
    if args.device:
        cmd[1:1] = ["-d", args.device]

    ppm = args.output + ".ppm"
    os.makedirs(os.path.dirname(ppm) or ".", exist_ok=True)
    settings = {
        "dpi": args.dpi,
        "lperiod": args.lperiod if args.lperiod is not None else DEFAULT_LPERIOD[args.dpi],
        "exposure_rgb": args.exposure if args.exposure is not None else [40000] * 3,
        "gain_rgb": args.gain,
        "offset_rgb": args.offset,
        "dark": args.dark,
        "area_mm": {"left": args.left, "top": args.top,
                    "width": args.width, "height": args.height},
    }
    print("gain   R/G/B: " + " ".join(f"{pga_gain(c):.2f}x" for c in args.gain))
    print("offset R/G/B: " + " ".join(f"{offset_mv(c):+.0f}mV" for c in args.offset))
    default_note = "" if args.lperiod is not None else " (driver default)"
    print(f"line period:  {settings['lperiod']}{default_note}", flush=True)

    with open(ppm, "wb") as out:
        res = subprocess.run(cmd, stdout=out, env=env)
    if res.returncode != 0:
        sys.exit(f"scanimage failed with exit code {res.returncode}")
    with open(args.output + ".json", "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")

    img = read_ppm16(ppm)
    print(f"\n{ppm}: {img.shape[1]}x{img.shape[0]} px")
    print_stats(img)


if __name__ == "__main__":
    main()
