{
  runNixOSTest,
  quibble,
  zfs-uefi,
  OVMF,
}:

# Boots quibble + zfs.efi against an encrypted ZFS pool and proves the EFI
# driver can unlock and mount it, and that the loader reads the Windows kernel
# from it.  This is the EFI half of the Windows-on-ZFS work, tested without
# Windows: a NixOS VM creates a real pool on a GPT disk (ESP + ZFS partition),
# makes the bootfs dataset encrypted with a passphrase, and fills it with the
# Windows path the loader will open.
#
# The nested QEMU then boots that disk with quibble, which loads zfs.efi and
# opens partition 2 for the SystemPath entry.  The driver prompts on the
# firmware console; the test types the passphrase over QMP, waits for the key
# store to report the unwrapped dataset key, and then for quibble to read
# Windows/System32/ntoskrnl.exe from the mounted dataset.
#
# zfs.efi is built with serial-test.patch (test-only) so those messages also go
# to COM1; without it they only reach quibble's graphical console.
let
  zfsSerial = zfs-uefi.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./serial-test.patch ];
  });

  # Runs inside the NixOS VM.  The pool image is a real disk with an ESP on
  # partition 1 and the pool on partition 2, which is what freeldr.ini's
  # partition(2) refers to.
  runSh = builtins.toFile "zfs-efi-run.sh" ''
    #!/bin/sh
    set -eu
    cp "$OVMF/FV/OVMF_VARS.fd" /root/VARS.fd
    chmod 644 /root/VARS.fd
    rm -f /root/serial.log /root/qmp.sock
    qemu-system-x86_64 -machine q35 -m 2048 -smp 2 -accel tcg \
      -display none -no-reboot -no-shutdown \
      -serial file:/root/serial.log \
      -qmp unix:/root/qmp.sock,server,nowait \
      -drive if=pflash,format=raw,unit=0,readonly=on,file="$OVMF/FV/OVMF_CODE.fd" \
      -drive if=pflash,format=raw,unit=1,file=/root/VARS.fd \
      -drive file=/root/disk.img,format=raw,if=ide &
    qpid=$!
    python3 /root/keys.py || rc=$?
    kill $qpid 2>/dev/null || true
    wait $qpid 2>/dev/null || true
    exit ''${rc:-0}
  '';

  # Types the passphrase at the driver prompt and waits for the key store to
  # report the unwrapped key.
  keysPy = builtins.toFile "zfs-efi-keys.py" ''
    import json, socket, time

    SERIAL = "/root/serial.log"
    QMP = "/root/qmp.sock"

    def serial():
        try:
            return open(SERIAL, "rb").read().decode("latin-1")
        except FileNotFoundError:
            return ""

    def wait_for(needle, timeout):
        end = time.time() + timeout
        while time.time() < end:
            if needle in serial():
                return True
            time.sleep(0.5)
        return False

    if not wait_for("ZFS: dataset is encrypted", 240):
        print("no key prompt on the serial console; tail:")
        print(serial()[-4000:])
        raise SystemExit(1)

    time.sleep(0.5)
    s = socket.socket(socket.AF_UNIX)
    s.settimeout(10)
    s.connect(QMP)
    s.recv(65536)

    def qmp(name, **args):
        s.sendall((json.dumps({"execute": name, "arguments": args}) + "\n").encode())
        time.sleep(0.15)
        try:
            s.recv(65536)
        except socket.timeout:
            pass

    qmp("qmp_capabilities")
    for ch in "correct horse battery staple":
        qmp("send-key", keys=[{"type": "qcode", "data": "spc" if ch == " " else ch}])
    qmp("send-key", keys=[{"type": "qcode", "data": "ret"}])

    if not wait_for("dataset key loaded: aes-256-gcm", 300):
        print("dataset key was not loaded; serial tail:")
        print(serial()[-6000:])
        raise SystemExit(1)

    if not wait_for("ZFS: mounted", 120):
        print("dataset did not mount; serial tail:")
        print(serial()[-6000:])
        raise SystemExit(1)

    if not wait_for("ZFS: read /Windows/system32/ntoskrnl.exe", 180):
        print("the loader did not read ntoskrnl.exe from the encrypted dataset; serial tail:")
        print(serial()[-6000:])
        raise SystemExit(1)

    qmp("screendump", filename="/root/screen.ppm", format="ppm")
    time.sleep(1)
    qmp("human-monitor-command", **{"command-line": "quit"})
    print(serial()[-4000:])
  '';
in
runNixOSTest {
  name = "zfs-uefi-encrypted-efi-boot";

  nodes.machine =
    { pkgs, ... }:
    {
      networking.hostId = "8425e349";
      boot.supportedFilesystems = [ "zfs" ];

      virtualisation = {
        memorySize = 4096;
        cores = 2;
      };

      environment.systemPackages = [
        pkgs.zfs
        pkgs.util-linux
        pkgs.qemu
        pkgs.OVMF
        pkgs.mtools
        pkgs.dosfstools
        pkgs.gptfdisk
        pkgs.python3
      ];
    };

  meta.timeout = 1800;

  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")

    # GPT disk: 64 MiB ESP, then the pool partition.
    machine.succeed("truncate -s 2G /root/disk.img")
    machine.succeed(
        "sgdisk --clear --new=1:2048:133119 --typecode=1:ef00 "
        "--new=2:133120:0 "
        "--typecode=2:6a898cc3-1dd2-11b2-99a6-080020736631 /root/disk.img"
    )
    machine.succeed("losetup -P /dev/loop0 /root/disk.img")
    machine.succeed("mkfs.vfat -F 32 -n ESP /dev/loop0p1")
    machine.succeed("mkdir -p /mnt/esp")
    machine.succeed("mount /dev/loop0p1 /mnt/esp")
    machine.succeed(
        "mkdir -p /mnt/esp/EFI/BOOT/drivers /mnt/esp/drivers"
    )
    machine.succeed(
        "cp ${quibble}/share/quibble/quibble.efi /mnt/esp/EFI/BOOT/BOOTX64.EFI"
    )
    machine.succeed(
        "cp ${quibble}/share/quibble/font.ttf /mnt/esp/EFI/BOOT/font.ttf"
    )
    # quibble opens "drivers" relative to its own directory, so the driver
    # belongs next to the loader (the root copy is harmless).
    machine.succeed(
        "cp ${zfsSerial}/share/zfs-uefi/zfs.efi /mnt/esp/EFI/BOOT/drivers/zfs.efi"
    )
    machine.succeed(
        "cp ${zfsSerial}/share/zfs-uefi/zfs.efi /mnt/esp/drivers/zfs.efi"
    )
    machine.succeed(
        "cat > /mnt/esp/EFI/BOOT/freeldr.ini <<'EOF'\n"
        "[FREELOADER]\n"
        "TimeOut=1\n"
        "DefaultOS=Windows\n"
        "\n"
        "[Operating Systems]\n"
        "Windows=\"Windows 11\"\n"
        "\n"
        "[Windows]\n"
        "SystemPath=multi(0)disk(0)rdisk(0)partition(2)\\Windows\n"
        "EOF"
    )
    machine.succeed("umount /mnt/esp")

    # Encrypted bootfs dataset, with the Windows tree the loader will open.
    machine.succeed(
        "zpool create -f -O casesensitivity=insensitive -O compression=off "
        "-O atime=off tank /dev/loop0p2"
    )
    machine.succeed("printf 'correct horse battery staple\\n' > /root/pass.txt")
    machine.succeed(
        "zfs create -o encryption=on -o keyformat=passphrase "
        "-o keylocation=file:///root/pass.txt tank/win"
    )
    machine.succeed("mkdir -p /tank/win/Windows/System32")
    machine.succeed("echo fake > /tank/win/Windows/System32/ntoskrnl.exe")
    machine.succeed("echo hello > /tank/win/hello.txt")
    machine.succeed("zpool set bootfs=tank/win tank")
    machine.succeed("sync")
    machine.succeed("zpool export tank")
    machine.succeed("losetup -d /dev/loop0")

    machine.succeed("cp ${runSh} /root/run.sh")
    machine.succeed("cp ${keysPy} /root/keys.py")
    machine.succeed("chmod +x /root/run.sh")
    machine.succeed("OVMF=${OVMF.fd} timeout 900 /root/run.sh", timeout=960)

    out = machine.succeed("cat /root/serial.log")
    assert "ZFS: dataset is encrypted" in out, out
    assert "dataset key loaded: aes-256-gcm" in out, out
    assert "ZFS: mounted" in out, out
    assert "ZFS: read /Windows/system32/ntoskrnl.exe" in out, out
    assert "dataset key unwrap failed" not in out, out
    print(out[-4000:])
  '';
}
