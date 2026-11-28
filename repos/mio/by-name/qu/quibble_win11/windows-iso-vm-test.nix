{
  runCommand,
  qemu,
  OVMF,
  python3,
  fetchurl,
}:

# Boots Microsoft's Windows 11 25H2 Enterprise Evaluation ISO under OVMF in
# QEMU and checks that the firmware dispatches the ISO's own UEFI boot entry and
# that Windows' boot environment takes over and draws its screen.
#
# The ISO is pinned here rather than taken from a path argument: this is the
# real-Windows fixture the quibble Windows work builds on, and pinning it keeps
# the fetch reproducible instead of depending on a manually downloaded file.
#
# This check only boots the installer image.  The unattended install that
# produces a disk quibble can boot needs a writable image and a long KVM run,
# which stays out of the checks (see quibble_patched/TODO.md).
let
  windowsIso = fetchurl {
    url = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_zh-cn.iso";
    hash = "sha256-e0rIc5G2WfdyQiloK2QiViiaHABQQFYknw8SApFX09I=";
  };

  # Boots the ISO with no disk attached, waits for OVMF to dispatch the CD's
  # UEFI entry, then screenshots until Windows' own UI is drawn.  OVMF's console
  # is a black background with text (a few percent of lit pixels); the Windows
  # boot environment paints a large coloured surface, so the ratio separates
  # "still in the firmware" from "Windows is running".
  probe = builtins.toFile "windows-iso-vm-probe.py" ''
    import json, os, shutil, socket, subprocess, sys, time

    serial, shot, ratio_script = sys.argv[1:4]
    threshold = float(os.environ["RATIO_THRESHOLD"])
    work = os.getcwd()
    qmp = os.path.join(work, "qmp.sock")
    vars_fd = os.path.join(work, "VARS.fd")
    serial = os.path.abspath(serial)
    shutil.copyfile(os.environ["OVMF_VARS"], vars_fd)
    os.chmod(vars_fd, 0o644)
    if os.path.exists(qmp):
        os.unlink(qmp)

    qemu = subprocess.Popen(
        [
            "qemu-system-x86_64", "-machine", "q35", "-m", "4096", "-smp", "2",
            # Windows 11 requires SSE4.2/POPCNT, which TCG's default qemu64 CPU
            # model does not expose; "max" does.
            "-accel", "tcg", "-cpu", "max", "-display", "none", "-no-reboot", "-no-shutdown",
            "-serial", "file:" + serial,
            "-qmp", "unix:" + qmp + ",server,nowait",
            "-drive", "if=pflash,format=raw,unit=0,readonly=on,file=" + os.environ["OVMF_CODE"],
            "-drive", "if=pflash,format=raw,unit=1,file=" + vars_fd,
            "-cdrom", os.environ["WINDOWS_ISO"],
        ],
        stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT,
    )

    def tail():
        try:
            return open(serial, "rb").read().decode("latin-1")
        except FileNotFoundError:
            return ""

    def stop():
        if qemu.poll() is None:
            qemu.terminate()
            try:
                qemu.wait(30)
            except subprocess.TimeoutExpired:
                qemu.kill()

    try:
        for _ in range(300):
            if os.path.exists(qmp):
                break
            time.sleep(0.1)
        s = socket.socket(socket.AF_UNIX)
        s.settimeout(120)
        s.connect(qmp)
        f = s.makefile("rwb")

        def read():
            while True:
                line = f.readline()
                if not line:
                    raise RuntimeError("qmp closed")
                msg = json.loads(line)
                if "event" not in msg:
                    return msg

        def cmd(name, **args):
            f.write((json.dumps({"execute": name, "arguments": args}) + "\n").encode())
            f.flush()
            return read()

        read()
        cmd("qmp_capabilities")

        # Wait for the firmware to dispatch a boot option.  Without a disk this
        # must be the ISO's UEFI entry.
        for _ in range(240):
            if "BdsDxe: starting Boot" in tail():
                break
            if qemu.poll() is not None:
                raise SystemExit("QEMU exited before dispatching a boot option:\n" + tail()[-3000:])
            time.sleep(0.5)
        else:
            raise SystemExit("firmware never dispatched a boot option:\n" + tail()[-3000:])

        # Windows' UEFI boot manager asks "Press any key to boot from CD or
        # DVD..." and returns EFI_TIMEOUT when ignored; OVMF then logs a failed
        # start and falls back to PXE.  Send keys across that window.
        for _ in range(24):
            cmd("send-key", keys=[{"type": "qcode", "data": "spc"}])
            time.sleep(0.35)

        best = 0.0
        tick = 0
        deadline = time.time() + 1500
        while time.time() < deadline:
            cmd("human-monitor-command", **{"command-line": "screendump " + os.path.abspath(shot)})
            time.sleep(1)
            ratio = subprocess.check_output(
                [sys.executable, ratio_script, shot]
            ).decode().strip()
            best = max(best, float(ratio))
            if best >= threshold:
                break
            if "failed to start Boot" in tail():
                break
            if qemu.poll() is not None:
                break
            tick += 1
            if tick % 12 == 0:
                print(f"waiting for the Windows boot screen: best {best:.2f}% non-black", flush=True)
            time.sleep(5)

        cmd("human-monitor-command", **{"command-line": "quit"})
        stop()

        log = tail()
        if "failed to start Boot" in log:
            raise SystemExit("firmware failed to start the ISO boot entry:\n" + log[-3000:])
        if "X64 Exception" in log or "failed to load" in log.lower():
            raise SystemExit("firmware reported a boot failure:\n" + log[-3000:])
        if not any(k in log for k in ("CDROM", "CD-ROM", "DVD-ROM")):
            raise SystemExit("firmware did not dispatch the ISO as a CD boot option:\n" + log[-3000:])
        if best < threshold:
            raise SystemExit(
                "Windows boot environment never drew its screen "
                f"(best {best:.2f}% non-black < {threshold:.0f}%):\n" + log[-3000:]
            )

        print(f"Windows boot screen drawn ({best:.2f}% non-black)")
    finally:
        stop()
  '';

  # Share of non-black pixels in a binary PPM screenshot.
  ratio = builtins.toFile "windows-iso-vm-ratio.py" ''
    import sys
    data = open(sys.argv[1], "rb").read()
    parts = data.split(b"\n", 3)
    pixels = parts[3]
    step = 3
    total = len(pixels) // step
    lit = sum(
        1
        for i in range(0, len(pixels) - step + 1, step)
        if pixels[i:i + step] != b"\x00\x00\x00"
    )
    print(f"{100.0 * lit / total:.2f}")
  '';
in
runCommand "windows11-iso-vm-boot"
  {
    nativeBuildInputs = [
      qemu
      python3
    ];
    OVMF_CODE = "${OVMF.fd}/FV/OVMF_CODE.fd";
    OVMF_VARS = "${OVMF.fd}/FV/OVMF_VARS.fd";
    WINDOWS_ISO = "${windowsIso}";
    RATIO_THRESHOLD = "15";
    meta = {
      description = "Boot Microsoft's Windows 11 25H2 ISO under OVMF and check that Windows' boot environment draws its screen";
      timeout = 3000;
    };
  }
  ''
    set -eu
    work=$(mktemp -d)
    cd "$work"
    export HOME=$work

    ${python3}/bin/python3 ${probe} serial.log screen.ppm ${ratio}

    ratio=$(${python3}/bin/python3 ${ratio} screen.ppm)
    echo "non-black pixels: $ratio%"

    mkdir -p $out
    cp serial.log screen.ppm $out/
    echo "$ratio" > $out/ratio.txt
  ''
