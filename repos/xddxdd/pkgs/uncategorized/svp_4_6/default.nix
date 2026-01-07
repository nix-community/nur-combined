{
  stdenv,
  buildFHSEnv,
  writeShellScriptBin,
  fetchurl,
  callPackage,
  makeDesktopItem,
  copyDesktopItems,
  # Dependencies
  ffmpeg,
  glibc,
  jq,
  lib,
  libmediainfo,
  libsForQt5,
  libusb1,
  ocl-icd,
  p7zip,
  patchelf,
  socat,
  vapoursynth,
  xdg-utils,
  xorg,
  zenity,
  # MPV dependencies
  mpv-unwrapped,
}:
################################################################################
# Based on svp package from AUR:
# https://aur.archlinux.org/packages/svp
################################################################################
let
  pname = "svp";
  version = "4.6.263";
  src = fetchurl {
    url = "https://web.archive.org/web/20250904130553if_/https://www.svp-team.com/files/svp4-linux.4.6.263.tar.bz2";
    name = "svp4-linux.tar.bz2";
    hash = "sha256-HyRDVFHVmTan/Si3QjGQpC3za30way10d0Hk79oXG98=";
  };

  mpvForSVP = callPackage ../svp/mpv.nix { inherit mpv-unwrapped; };

  # Script provided by GitHub user @xrun1
  # https://github.com/xddxdd/nur-packages/issues/31#issuecomment-1812591688
  fakeLsof = writeShellScriptBin "lsof" ''
    for arg in "$@"; do
      if [ -S "$arg" ]; then
        printf %s p
        echo '{"command": ["get_property", "pid"]}' |
          ${lib.getExe socat} - "UNIX-CONNECT:$arg" |
          ${lib.getExe jq} -Mr .data
        printf '\n'
      fi
    done
  '';

  libraries = [
    fakeLsof
    ffmpeg.bin
    glibc
    zenity
    libmediainfo
    libsForQt5.qtbase
    libsForQt5.qtwayland
    libsForQt5.qtdeclarative
    libsForQt5.qtscript
    libsForQt5.qtsvg
    libusb1
    mpvForSVP
    ocl-icd
    stdenv.cc.cc.lib
    vapoursynth
    xdg-utils
    xorg.libX11
  ];

  svp-dist = stdenv.mkDerivation (finalAttrs: {
    pname = "svp-dist";
    inherit version src;

    nativeBuildInputs = [
      p7zip
      patchelf
    ];
    dontFixup = true;

    unpackPhase = ''
      tar xf $src
    '';

    buildPhase = ''
      mkdir installer
      LANG=C grep --only-matching --byte-offset --binary --text  $'7z\xBC\xAF\x27\x1C' "svp4-linux-64.run" |
        cut -f1 -d: |
        while read ofs; do dd if="svp4-linux-64.run" bs=1M iflag=skip_bytes status=none skip=$ofs of="installer/bin-$ofs.7z"; done
    '';

    installPhase = ''
      mkdir -p $out/opt
      for f in "installer/"*.7z; do
        7z -bd -bb0 -y x -o"$out/opt/" "$f" || true
      done

      for SIZE in 32 48 64 128; do
        install -Dm644 "$out/opt/svp-manager4-''${SIZE}.png" "$out/share/icons/hicolor/''${SIZE}x''${SIZE}/apps/svp-manager4.png"
      done
      rm -f $out/opt/{add,remove}-menuitem.sh
    '';
  });

  fhs = buildFHSEnv {
    name = "SVPManager";
    targetPkgs = _pkgs: libraries;
    runScript = "${svp-dist}/opt/SVPManager";
    unshareUser = false;
    unshareIpc = false;
    unsharePid = false;
    unshareNet = false;
    unshareUts = false;
    unshareCgroup = false;
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];

  postInstall = ''
    install -Dm755 ${fhs}/bin/SVPManager $out/bin/SVPManager

    mkdir -p $out/share
    ln -s ${svp-dist}/share/icons $out/share/icons
  '';

  passthru.mpv = mpvForSVP;

  desktopItems = [
    (makeDesktopItem {
      name = "svp-manager4";
      exec = "${fhs}/bin/SVPManager %f";
      desktopName = "SVP 4 Linux";
      genericName = "Real time frame interpolation";
      icon = "svp-manager4";
      categories = [
        "AudioVideo"
        "Player"
        "Video"
      ];
      mimeTypes = [
        "video/x-msvideo"
        "video/x-matroska"
        "video/webm"
        "video/mpeg"
        "video/mp4"
      ];
      terminal = false;
      startupNotify = true;
    })
  ];

  meta = {
    mainProgram = "SVPManager";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "SmoothVideo Project 4 (SVP4) converts any video to 60 fps (and even higher) and performs this in real time right in your favorite video player";
    homepage = "https://www.svp-team.com/wiki/SVP:Linux";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
