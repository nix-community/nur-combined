{
  pkgs ? import <nixpkgs> { },
  package ? (import ../../default.nix { inherit pkgs; }).sfl,
}:
let
  inherit (pkgs) lib;
  rootExports = import ../../default.nix { pkgs = null; };
  evaluate =
    extra:
    (import (pkgs.path + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      system = pkgs.stdenv.hostPlatform.system;
      modules = [
        ../../modules/sfl.nix
        extra
      ];
    }).config;
  disabled = evaluate { };
  enabled = evaluate { services.sfl.enable = true; };
  custom = evaluate {
    services.sfl = {
      enable = true;
      package = pkgs.hello;
    };
  };
  insecure = evaluate {
    services.sfl = {
      enable = true;
      insecureMode = true;
    };
  };
  restricted = evaluate {
    services.sfl = {
      enable = true;
      insecureMode = false;
    };
  };
  overridden = package.overrideAttrs {
    version = "1.14.4";
    __intentionallyOverridingVersion = true;
  };
  checks = {
    packageExported = builtins.elem "sfl" (builtins.attrNames rootExports);
    moduleWithoutPkgs = builtins.isPath rootExports.nixosModules.sfl;
    platforms =
      package.meta.platforms == [
        "aarch64-linux"
        "x86_64-linux"
      ];
    overriddenUrl = lib.hasInfix "/v1.14.4/SFL-1.14.4-" overridden.src.url;
    disabledByDefault =
      !disabled.services.sfl.enable && !(builtins.elem package disabled.systemd.packages);
    packageDefault = disabled.services.sfl.package.pname == "sfl";
    enabledPolkit = enabled.security.polkit.enable;
    securityUnmanaged =
      enabled.services.sfl.insecureMode == null
      && enabled.systemd.services.sing-box-daemon.preStart == "";
    enableInsecureMode = lib.hasInfix "service set-insecure-mode true --working-directory /var/lib/sing-box-daemon" insecure.systemd.services.sing-box-daemon.preStart;
    restoreRestrictions = lib.hasInfix "service set-insecure-mode false --working-directory /var/lib/sing-box-daemon" restricted.systemd.services.sing-box-daemon.preStart;
    enabledPackages =
      builtins.elem package enabled.environment.systemPackages
      && builtins.elem package enabled.systemd.packages;
    enabledServiceWantedBy =
      enabled.systemd.services.sing-box-daemon.wantedBy == [ "multi-user.target" ];
    customPackage =
      builtins.elem pkgs.hello custom.environment.systemPackages
      && builtins.elem pkgs.hello custom.systemd.packages;
  };
  failures = lib.attrNames (lib.filterAttrs (_: passed: !passed) checks);
in
assert lib.assertMsg (failures == [ ]) "Failed checks: ${lib.concatStringsSep ", " failures}";
pkgs.runCommand "sfl-packaging-check"
  {
    nativeBuildInputs = [ pkgs.python3 ];
  }
  ''
    test -x ${package}/bin/sfl
    test -x ${package}/bin/sing-box-daemon
    test -x ${package}/opt/sing-box/sing-box
    test -x ${package}/opt/sing-box/resources/daemon/sing-box-daemon
    test -f ${package}/opt/sing-box/resources/native/wayland_menu.node
    test ! -e ${package}/bin/sing-box
    test -f ${package}/share/applications/sing-box.desktop
    test -f ${package}/share/metainfo/io.nekohasekai.sfl.metainfo.xml
    test -f ${package}/share/mime/packages/sing-box.xml
    test -f ${package}/share/polkit-1/actions/io.nekohasekai.sfl.policy
    test -f ${package}/share/icons/hicolor/512x512/apps/sing-box.png
    test -f ${package}/share/icons/hicolor/1024x1024/apps/sing-box.png
    test -f ${package}/lib/systemd/system/sing-box-daemon.service

    grep -Fq "Exec=${package}/bin/sfl %U" ${package}/share/applications/sing-box.desktop
    grep -Fq "<binary>sfl</binary>" ${package}/share/metainfo/io.nekohasekai.sfl.metainfo.xml
    grep -Fq "ExecStart=${package}/bin/sing-box-daemon run --working-directory /var/lib/sing-box-daemon --socket /run/sing-box.socket" \
      ${package}/lib/systemd/system/sing-box-daemon.service

    ${package}/bin/sing-box-daemon version > daemon-version.txt
    grep -Fq "sing-box-daemon version ${package.version}" daemon-version.txt

    python3 - "${package}/bin/sing-box-daemon" "${package}/opt/sing-box/resources" <<'PY'
    import os
    import socket
    import struct
    import subprocess
    import sys
    import tempfile
    import time
    import zlib
    from pathlib import Path

    daemon = sys.argv[1]
    resources = Path(sys.argv[2])

    for name, expected_size in (
        ("tray.png", (16, 16)),
        ("tray@2x.png", (32, 32)),
        ("trayStopped.png", (16, 16)),
        ("trayStopped@2x.png", (32, 32)),
    ):
        data = (resources / name).read_bytes()
        assert data.startswith(b"\x89PNG\r\n\x1a\n"), f"invalid PNG header in {name}"
        pos = 8
        width = height = bit_depth = color_type = 0
        idat = bytearray()
        while pos < len(data):
            length, chunk_type = struct.unpack(">I4s", data[pos : pos + 8])
            chunk = data[pos + 8 : pos + 8 + length]
            if chunk_type == b"IHDR":
                width, height, bit_depth, color_type = struct.unpack(">IIBB", chunk[:10])
            elif chunk_type == b"IDAT":
                idat.extend(chunk)
            pos += 12 + length
        assert (width, height) == expected_size, f"unexpected size {(width, height)} for {name}"
        assert (bit_depth, color_type) == (8, 6), f"unexpected format {(bit_depth, color_type)} for {name}"
        raw = zlib.decompress(bytes(idat))
        stride = width * 4
        visible_white = 0
        for y in range(height):
            row = raw[y * (stride + 1) : (y + 1) * (stride + 1)]
            assert row[0] == 0, f"expected filter 0 in {name}"
            for x in range(width):
                r, g, b, a = row[1 + x * 4 : 1 + (x + 1) * 4]
                if a > 0:
                    assert (r, g, b) == (255, 255, 255), f"non-white pixel {(r, g, b, a)} in {name}"
                    visible_white += 1
        assert visible_white > 0, f"no visible pixels in {name}"

    with tempfile.TemporaryDirectory(prefix="sfl-test-") as tmp:
        root = Path(tmp)
        worker_sock = root / "worker.sock"
        worker = subprocess.Popen(
            [daemon, "worker", "--socket", str(worker_sock), "--parent-pid", str(os.getpid())],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        try:
            assert worker.stdout is not None
            line = worker.stdout.readline().strip()
            assert line == "READY", f"unexpected worker output: {line}"
            assert worker_sock.is_socket()
        finally:
            worker.terminate()
            worker.wait(timeout=5)

        workdir = root / "workdir"
        daemon_sock = root / "daemon.sock"
        service = subprocess.Popen(
            [daemon, "run", "--working-directory", str(workdir), "--socket", str(daemon_sock)],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        try:
            deadline = time.monotonic() + 10.0
            while not daemon_sock.is_socket():
                assert service.poll() is None, "daemon exited early"
                assert time.monotonic() < deadline, "daemon socket timeout"
                time.sleep(0.05)
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
                client.settimeout(5.0)
                client.connect(str(daemon_sock))
        finally:
            service.terminate()
            service.wait(timeout=5)
    PY

    touch "$out"
  ''
