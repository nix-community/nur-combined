{
  libjpeg_turbo,
  libxkbcommon,
  libseccomp,
  libselinux,
  stdenvNoCC,
  fontconfig,
  util-linux,
  libsecret,
  libepoxy,
  elfutils,
  keyutils,
  fetchurl,
  fetchzip,
  freetype,
  harfbuzz,
  libxml2,
  libxslt,
  libwebp,
  wayland,
  enchant,
  openssl,
  systemd,
  libGLU,
  libffi,
  libx11,
  libpng,
  libdrm,
  libcap,
  libpsl,
  hyphen,
  pixman,
  stdenv,
  pcre2,
  libva,
  libGL,
  cairo,
  pango,
  expat,
  krb5,
  pcre,
  zstd,
  mesa,
  gtk3,
  lz4,
  icu,
  lib,
  xz,
}: let
  ver = lib.helper.read ./version.json;

  pname = "streamnook";
  inherit (ver) version;

  # NOTE: In the future we can simplify this, once the linux version officially drops on github.
  platform = stdenvNoCC.hostPlatform.system;
  src =
    (
      if lib.helper.unpackPlatform platform ver
      then fetchzip
      else fetchurl
    )
    (lib.helper.getPlatform platform ver);

  meta = {
    description = "A native desktop client for Twitch, Kick and YouTube multi-streaming";
    homepage = "https://streamnook.app";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "streamnook";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopId = "StreamNook";
      desktopName = "StreamNook";
      icon = "StreamNook";
      startupWMClass = "StreamNook";
      categories = ["Video" "AudioVideo"];
      extraDesktopItem = {
        mimeTypes = ["x-scheme-handler/streamnook"];
      };

      extraPkgs = [
        stdenv.cc.cc.lib
        libjpeg_turbo
        libxkbcommon
        fontconfig
        util-linux
        libseccomp
        libselinux
        libsecret
        harfbuzz
        freetype
        libepoxy
        elfutils
        keyutils
        wayland
        enchant
        libxml2
        libxslt
        libwebp
        openssl
        systemd
        libGLU
        libffi
        libx11
        libpng
        libdrm
        hyphen
        pixman
        libcap
        libpsl
        cairo
        pango
        expat
        libGL
        pcre2
        libva
        zstd
        mesa
        gtk3
        krb5
        pcre
        icu
        lz4
        xz
      ];
    }
