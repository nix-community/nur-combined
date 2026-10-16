{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  autoPatchelfHook,
  wrapGAppsHook3,
  zstd,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  gtk4,
  libappindicator-gtk3,
  libdbusmenu,
  libdrm,
  libgbm,
  libGL,
  libnotify,
  libpulseaudio,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxshmfence,
  nspr,
  nss,
  pango,
  pciutils,
  pipewire,
  speechd-minimal,
  systemd,
  vulkan-loader,
  wayland,
  xdg-utils,
  xprop,
  xrdb,
  writeShellApplication,
  python3,
  nix-update,
  nix,
  gh,
}:
let
  sources = {
    x86_64-linux = {
      arch = "x64";
      hash = "sha256-0yk9l/zIYFhpYkQgdQxWXwiCiO7VJVYcOv9g9Mg6kvY=";
    };
    aarch64-linux = {
      arch = "aarch64";
      hash = "sha256-phlP3FXC3rwea8ng2d51YcchPXqPc3NLZ/08HGxXXww=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
  runtimeLibraries = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    gtk4
    libappindicator-gtk3
    libdbusmenu
    libdrm
    libgbm
    libGL
    libnotify
    libpulseaudio
    libsecret
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxkbfile
    libxrandr
    libxshmfence
    nspr
    nss
    pango
    pciutils
    pipewire
    speechd-minimal
    stdenv.cc.cc
    systemd
    vulkan-loader
    wayland
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sfl";
  version = "1.15.0-alpha.12";

  src = fetchurl {
    url = "https://github.com/SagerNet/sing-box/releases/download/v${finalAttrs.version}/SFL-${finalAttrs.version}-${source.arch}.pkg.tar.zst";
    inherit (source) hash;
  };

  sourceRoot = ".";
  dontBuild = true;
  dontStrip = true;
  dontWrapGApps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    python3
    wrapGAppsHook3
    zstd
  ];

  buildInputs = runtimeLibraries;
  runtimeDependencies = runtimeLibraries;

  unpackPhase = ''
    runHook preUnpack
    tar --zstd -xf "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/opt" "$out/lib/systemd/system" "$out/share"
    cp -r opt/sing-box "$out/opt/sing-box"
    cp -r usr/share/* "$out/share/"
    cp usr/lib/systemd/system/sing-box-daemon.service "$out/lib/systemd/system/sing-box-daemon.service"

    python3 - "$out/opt/sing-box/resources" <<'PY'
    from pathlib import Path
    import struct
    import sys
    import zlib

    resources = Path(sys.argv[1])


    def paeth(a: int, b: int, c: int) -> int:
        p = a + b - c
        pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
        if pa <= pb and pa <= pc:
            return a
        return b if pb <= pc else c


    def make_chunk(chunk_type: bytes, payload: bytes) -> bytes:
        crc = zlib.crc32(chunk_type + payload) & 0xFFFFFFFF
        return struct.pack(">I4s", len(payload), chunk_type) + payload + struct.pack(">I", crc)


    def convert_template(src: Path, dst: Path) -> None:
        data = src.read_bytes()
        assert data.startswith(b"\x89PNG\r\n\x1a\n"), f"invalid PNG header in {src}"
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
        assert bit_depth == 8 and color_type in (4, 6), f"unsupported PNG format in {src}"
        bpp = 2 if color_type == 4 else 4
        stride = width * bpp
        raw = zlib.decompress(bytes(idat))
        recon = bytearray(height * stride)
        for y in range(height):
            row_start = y * (stride + 1)
            filter_type = raw[row_start]
            row = raw[row_start + 1 : row_start + 1 + stride]
            for x in range(stride):
                left = recon[y * stride + x - bpp] if x >= bpp else 0
                up = recon[(y - 1) * stride + x] if y > 0 else 0
                up_left = recon[(y - 1) * stride + x - bpp] if (y > 0 and x >= bpp) else 0
                if filter_type == 0:
                    val = row[x]
                elif filter_type == 1:
                    val = (row[x] + left) & 0xFF
                elif filter_type == 2:
                    val = (row[x] + up) & 0xFF
                elif filter_type == 3:
                    val = (row[x] + (left + up) // 2) & 0xFF
                elif filter_type == 4:
                    val = (row[x] + paeth(left, up, up_left)) & 0xFF
                else:
                    raise ValueError(f"unsupported PNG filter {filter_type} in {src}")
                recon[y * stride + x] = val

        out = bytearray()
        for y in range(height):
            out.append(0)
            for x in range(width):
                alpha = recon[y * stride + x * bpp + (bpp - 1)]
                out.extend((255, 255, 255, alpha) if alpha else (0, 0, 0, 0))

        ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
        png = (
            b"\x89PNG\r\n\x1a\n"
            + make_chunk(b"IHDR", ihdr)
            + make_chunk(b"IDAT", zlib.compress(bytes(out), 9))
            + make_chunk(b"IEND", b"")
        )
        dst.write_bytes(png)


    for stem in ("tray", "trayStopped"):
        convert_template(resources / f"{stem}Template.png", resources / f"{stem}.png")
        convert_template(resources / f"{stem}Template@2x.png", resources / f"{stem}@2x.png")
    PY

    substituteInPlace "$out/share/applications/sing-box.desktop" \
      --replace-fail "Exec=/opt/sing-box/sing-box %U" "Exec=$out/bin/sfl %U"
    substituteInPlace "$out/share/metainfo/io.nekohasekai.sfl.metainfo.xml" \
      --replace-fail "<binary>sing-box</binary>" "<binary>sfl</binary>"
    substituteInPlace "$out/lib/systemd/system/sing-box-daemon.service" \
      --replace-fail "/opt/sing-box/resources/daemon/sing-box-daemon" "$out/bin/sing-box-daemon"

    ln -s "$out/opt/sing-box/resources/daemon/sing-box-daemon" "$out/bin/sing-box-daemon"
    runHook postInstall
  '';

  preFixup = ''
    makeWrapper "$out/opt/sing-box/sing-box" "$out/bin/sfl" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : "${
        lib.makeBinPath [
          xdg-utils
          xprop
          xrdb
        ]
      }"
  '';

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-sfl";
      runtimeInputs = [
        python3
        nix-update
        nix
        gh
      ];
      text = ''
        exec python3 pkgs/sfl/update.py "$@"
      '';
    });
    tests.packaging = callPackage ../../tests/pkgs/sfl.nix {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Linux desktop client for sing-box";
    homepage = "https://github.com/SagerNet/sing-box-for-desktop";
    changelog = "https://github.com/SagerNet/sing-box/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "sfl";
  };
})
