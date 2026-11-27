{
  runCommand,
  qemu,
  OVMF,
  mtools,
  dosfstools,
  gptfdisk,
  python3,
  quibble,
}:

# Boots the packaged loader under OVMF in QEMU and checks that it takes over the
# console and draws its menu.  Two runs make the assertion meaningful:
#   * a correct ESP (freeldr.ini next to the loader) must reach BdsDxe's
#     "starting Boot..." and must NOT fall back to the firmware boot menu;
#   * an ESP without freeldr.ini must fall back, which shows the first run would
#     fail if the layout regressed.
let
  # The loader reads freeldr.ini from its own directory, so this test writes a
  # minimal config instead of shipping upstream's release one.
  freeldrIni = builtins.toFile "freeldr.ini" ''
    [FREELOADER]
    TimeOut=60
    DefaultOS=Test

    [Operating Systems]
    Test="Test"

    [Test]
    SystemPath=multi(0)disk(0)rdisk(0)partition(1)\Windows
  '';

  probe = builtins.toFile "quibble-vm-probe.py" ''
    import json, os, shutil, socket, subprocess, sys, time

    disk, serial, shot = sys.argv[1:4]
    qmp = os.path.abspath("qmp.sock")
    vars_fd = os.path.abspath("VARS.fd")
    serial = os.path.abspath(serial)
    shutil.copyfile(os.environ["OVMF_VARS"], vars_fd)
    os.chmod(vars_fd, 0o644)
    if os.path.exists(qmp):
        os.unlink(qmp)
    qemu = subprocess.Popen(
        [
            "qemu-system-x86_64", "-machine", "q35", "-m", "2048", "-smp", "2",
            "-accel", "tcg", "-display", "none", "-no-reboot", "-no-shutdown",
            "-serial", "file:" + serial,
            "-qmp", "unix:" + qmp + ",server,nowait",
            "-drive", "if=pflash,format=raw,unit=0,readonly=on,file=" + os.environ["OVMF_CODE"],
            "-drive", "if=pflash,format=raw,unit=1,file=" + vars_fd,
            "-drive", "if=ide,format=raw,file=" + os.path.abspath(disk),
        ],
        stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT,
    )

    def tail():
        try:
            return open(serial, "rb").read().decode("latin-1")
        except FileNotFoundError:
            return ""

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
        # Wait until the firmware has dispatched our boot option (or given up),
        # then give the graphics console time to be drawn.
        for _ in range(240):
            if "BdsDxe: starting Boot" in tail() or "BdsDxe: failed to load" in tail():
                break
            time.sleep(0.5)
        time.sleep(5)
        cmd("human-monitor-command", **{"command-line": "screendump " + os.path.abspath(shot)})
        time.sleep(1)
        cmd("human-monitor-command", **{"command-line": "quit"})
    finally:
        if qemu.poll() is None:
            qemu.terminate()
            try:
                qemu.wait(30)
            except subprocess.TimeoutExpired:
                qemu.kill()
  '';

  # Share of non-black pixels in a binary PPM screenshot.
  ratio = builtins.toFile "quibble-vm-ratio.py" ''
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
runCommand "quibble-vm-boot"
  {
    nativeBuildInputs = [
      qemu
      mtools
      dosfstools
      gptfdisk
      python3
    ];
    OVMF_CODE = "${OVMF.fd}/FV/OVMF_CODE.fd";
    OVMF_VARS = "${OVMF.fd}/FV/OVMF_VARS.fd";
    passthru = { inherit quibble; };
    meta = {
      description = "Boot ${quibble.name} under OVMF and check that its menu is drawn";
      timeout = 900;
    };
  }
  ''
    set -eu
    work=$(mktemp -d)
    cd "$work"
    export HOME=$work

    make_disk() {
      # $1 = target image, $2 = yes/no whether freeldr.ini sits next to the loader
      rm -f "$1" esp.img
      truncate -s 128M "$1"
      sgdisk --clear --new=1:2048:133119 --typecode=1:ef00 "$1" > /dev/null
      truncate -s 64M esp.img
      mkfs.vfat -F 32 -s 1 -n ESP esp.img > /dev/null
      mmd -i esp.img ::/EFI ::/EFI/BOOT ::/drivers
      mcopy -i esp.img ${quibble}/share/quibble/quibble.efi ::/EFI/BOOT/BOOTX64.EFI
      mcopy -i esp.img ${quibble}/share/quibble/font.ttf ::/EFI/BOOT/font.ttf
      if [ "$2" = yes ]; then
        mcopy -i esp.img ${freeldrIni} ::/EFI/BOOT/freeldr.ini
      fi
      for driver in ${quibble}/share/quibble/drivers/*.efi; do
        mcopy -i esp.img "$driver" "::/drivers/$(basename "$driver")"
      done
      dd if=esp.img of="$1" bs=1M seek=1 conv=notrunc status=none
    }

    echo "== run 1: freeldr.ini next to the loader"
    make_disk good.img yes
    ${python3}/bin/python3 ${probe} good.img good-serial.log good.ppm
    good_ratio=$(${python3}/bin/python3 ${ratio} good.ppm)
    echo "non-black pixels: $good_ratio%"
    if grep -q "X64 Exception" good-serial.log; then
      echo "firmware raised an exception"
      cat good-serial.log
      exit 1
    fi
    if ! grep -q "BdsDxe: starting Boot" good-serial.log; then
      echo "firmware never started the loader"
      cat good-serial.log
      exit 1
    fi
    if grep -q "Please select boot device" good-serial.log; then
      echo "firmware fell back to its boot menu although freeldr.ini was present"
      cat good-serial.log
      exit 1
    fi

    echo "== run 2: no freeldr.ini, the check must see the fallback"
    make_disk bad.img no
    ${python3}/bin/python3 ${probe} bad.img bad-serial.log bad.ppm
    bad_ratio=$(${python3}/bin/python3 ${ratio} bad.ppm)
    echo "non-black pixels: $bad_ratio%"
    if ! grep -q "Please select boot device" bad-serial.log; then
      echo "expected the firmware boot menu without freeldr.ini, got:"
      cat bad-serial.log
      exit 1
    fi

    echo "menu kept with freeldr.ini ($good_ratio% drawn), firmware fallback without it ($bad_ratio%)"
    mkdir -p $out
    cp good.ppm bad.ppm good-serial.log bad-serial.log $out/
  ''
