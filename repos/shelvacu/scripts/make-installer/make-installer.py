import argparse
import ipaddress
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile


def run(*args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


settings = json.loads(Path(sys.argv.pop(1)).read_text())
parser = argparse.ArgumentParser(
    description="Prepare installer media or serve PXE with a boot-time SSH signing CA."
)
parser.add_argument("format", choices=["iso", "usb", "pxe"])
parser.add_argument(
    "output",
    type=Path,
    nargs="?",
    help="New ISO file or whole USB device (omit for PXE)",
)
parser.add_argument(
    "--principals", default="vacuInstaller", help="Comma-separated SSH hostnames/IPs"
)
parser.add_argument(
    "--validity", default="+52w", help="ssh-keygen certificate validity"
)
parser.add_argument(
    "--ca-key", type=Path, help="Use a decrypted CA key instead of SOPS"
)
parser.add_argument(
    "--yes", action="store_true", help="Confirm overwriting the USB device"
)
parser.add_argument(
    "--firewall",
    choices=["ask", "open", "skip"],
    default="ask",
    help="PXE: offer to open temporary NixOS firewall ports (default: ask)",
)
parser.add_argument(
    "--port", type=int, default=8080, help="PXE HTTP port (default: 8080)"
)
parser.add_argument("--listen-addr", default="0.0.0.0", help="PXE server IPv4 address")
parser.add_argument(
    "--memtest", action="store_true", help="PXE: boot Memtest86+ instead of the installer"
)
args = parser.parse_args()
if args.memtest and args.format != "pxe":
    parser.error("--memtest requires PXE mode")
if args.format == "pxe":
    if args.output is not None:
        parser.error("PXE serves directly; omit the output path")
    if not 1 <= args.port <= 65535:
        parser.error("--port must be between 1 and 65535")
    try:
        ipaddress.IPv4Address(args.listen_addr)
    except ipaddress.AddressValueError:
        parser.error("--listen-addr must be an IPv4 address")
elif args.output is None:
    parser.error("ISO and USB require an output path")
if (
    not args.principals
    or not args.validity
    or any(c in args.principals + args.validity for c in "\n\r\0")
):
    parser.error("Principals and validity must be nonempty, single-line values")
output = args.output.absolute() if args.output is not None else None
if args.format == "usb":
    if not output.is_block_device():
        parser.error("USB output must be a block device")
    info = json.loads(
        subprocess.check_output(
            ["lsblk", "--json", "--output", "TYPE,MOUNTPOINTS", str(output)]
        )
    )

    def mounted(dev):
        return any(dev.get("mountpoints", [])) or any(
            mounted(c) for c in dev.get("children", [])
        )

    if info["blockdevices"][0]["type"] != "disk" or mounted(info["blockdevices"][0]):
        parser.error("USB output must be a whole disk with no mounted filesystems")
    if not args.yes:
        parser.error("Writing erases the entire USB device; pass --yes to confirm")
elif output is not None and output.exists():
    parser.error("Output already exists")

os.umask(0o077)
with tempfile.TemporaryDirectory(prefix="installer-") as tmp:
    work = Path(tmp)
    if not args.memtest:
        keys = work / "installer-ssh-ca"
        keys.mkdir()
        ca = keys / "key"
        if args.ca_key is None:
            with ca.open("wb") as stream:
                run(
                    settings["sops"],
                    "decrypt",
                    "--input-type",
                    "binary",
                    "--output-type",
                    "binary",
                    settings["ca"],
                    stdout=stream,
                )
        else:
            shutil.copyfile(args.ca_key, ca)
        public = (
            subprocess.check_output(["ssh-keygen", "-y", "-f", str(ca)])
            .decode()
            .split()[:2]
        )
        if public != Path(settings["caPublic"]).read_text().split()[:2]:
            parser.error("CA key does not match installer_ssh_ca")
        (keys / "principals").write_text(args.principals.lower())
        (keys / "validity").write_text(args.validity)
        archive = work / "ca.cpio"
        with archive.open("wb") as stream:
            run(
                "cpio",
                "--create",
                "--format=newc",
                "--quiet",
                cwd=work,
                input="\n".join(
                    ["installer-ssh-ca"]
                    + [str(p.relative_to(work)) for p in keys.iterdir()]
                ).encode()
                + b"\n",
                stdout=stream,
            )

    def append_ca(initrd):
        with initrd.open("ab") as stream, archive.open("rb") as source:
            # The kernel requires uncompressed cpio headers to be four-byte aligned.
            stream.write(b"\0" * (-stream.tell() % 4))
            shutil.copyfileobj(source, stream)

    if args.format == "pxe":
        if args.memtest:
            payload = [settings["memtest"]]
        else:
            initrd = work / "initrd"
            shutil.copyfile(settings["pxeInitrd"], initrd)
            append_ca(initrd)
            payload = [
                settings["pxeKernel"], str(initrd), "--cmdline", settings["pxeCmdline"]
            ]
        root = [] if os.geteuid() == 0 else ["sudo"]
        firewall = settings["firewall"]
        backend = "none"
        if args.firewall != "skip":
            backend = subprocess.check_output(
                [*root, firewall, "probe"], text=True
            ).strip()
            if backend == "none" and args.firewall == "open":
                parser.error("No supported NixOS firewall found; use --firewall skip")
            if backend != "none" and args.firewall == "ask":
                if not sys.stdin.isatty():
                    parser.error(
                        "Use --firewall open or --firewall skip without a terminal"
                    )
                answer = input(
                    f"Temporarily open UDP 67,69,4011 and TCP {args.port} "
                    f"in the NixOS {backend} firewall? [y/N] "
                )
                if answer.lower() not in ("y", "yes"):
                    backend = "none"
        unit = "installer-pxe-" + os.urandom(8).hex()
        command = [
            *root,
            "systemd-run",
            "--unit=" + unit,
            "--collect",
            "--wait",
            "--pipe",
            "--service-type=exec",
        ]
        if backend != "none":
            chain = f"temp-vacu-make-installer-{os.getpid()}"
            for prop, action in [("ExecStartPre", "open"), ("ExecStopPost", "close")]:
                command.append(
                    f"--property={prop}={firewall} {action} {backend} {chain} {args.port}"
                )
        command += [
            settings["pixiecore"],
            "boot",
            *payload,
            "--dhcp-no-bind",
            "--debug",
            "--log-timestamps",
            "--port",
            str(args.port),
            "--status-port",
            str(args.port),
            "--listen-addr",
            args.listen_addr,
        ]
        target = "Memtest86+" if args.memtest else "installer"
        print(f"Serving {target} with {unit}. Press Ctrl-C to stop.", flush=True)

        def stop_on_signal(signum, frame):
            raise KeyboardInterrupt

        signal.signal(signal.SIGINT, stop_on_signal)
        signal.signal(signal.SIGTERM, stop_on_signal)
        with subprocess.Popen(command) as server:
            try:
                returncode = server.wait()
                if returncode:
                    raise subprocess.CalledProcessError(returncode, command)
                raise RuntimeError("PXE server exited unexpectedly; see its output above")
            except KeyboardInterrupt:
                signal.signal(signal.SIGINT, signal.SIG_IGN)
                signal.signal(signal.SIGTERM, signal.SIG_IGN)
                # Stop the service before Popen.__exit__ waits for systemd-run.
                run(*root, "systemctl", "stop", unit + ".service")
    else:
        initrd = work / "initrd"
        shutil.copyfile(settings["isoInitrd"], initrd)
        append_ca(initrd)
        paths = []
        if not any(
            entry["source"] == settings["isoInitrd"]
            for entry in settings["isoContents"]
        ):
            parser.error("ISO contents do not include the expected initrd")
        for entry in settings["isoContents"]:
            source = entry["source"]
            if source == settings["isoInitrd"]:
                source = str(initrd)
            if entry["target"].lstrip("/") == "isolinux/isolinux.bin":
                boot = work / "isolinux.bin"
                shutil.copyfile(source, boot)
                source = str(boot)
            paths.append((entry["target"].lstrip("/"), source))
        paths.append(("nix-store.squashfs", settings["isoSquashfs"]))

        def escape_path(path):
            return path.replace("\\", "\\\\").replace("=", "\\=")

        pathlist = work / "pathlist"
        pathlist.write_text(
            "".join(
                f"{escape_path(target)}={escape_path(source)}\n"
                for target, source in paths
            )
        )
        image = output if args.format == "iso" else work / "installer.iso"
        run(
            "xorriso",
            "-as",
            "mkisofs",
            "-iso-level",
            "3",
            "-volid",
            settings["isoVolumeID"],
            "-appid",
            "nixos",
            "-publisher",
            "nixos",
            "-graft-points",
            "-full-iso9660-filenames",
            "-joliet",
            *settings["isoBootFlags"],
            "-r",
            "-path-list",
            str(pathlist),
            "-output",
            str(image),
        )
        if args.format == "usb":
            run(
                "dd",
                "if=" + str(image),
                "of=" + str(output),
                "bs=4M",
                "status=progress",
                "conv=fsync",
            )
