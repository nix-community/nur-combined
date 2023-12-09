{
  stdenv,
  buildFHSEnv,
  writeShellScriptBin,
  fetchurl,
  callPackage,
  # Dependencies
  ffmpeg,
  glibc,
  gnome,
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
  writeText,
  xdg-utils,
  xorg,
  ...
}:
################################################################################
# Based on svp package from AUR:
# https://aur.archlinux.org/packages/svp
################################################################################
let
  mpvForSVP = callPackage ./mpv.nix {};

  # Script provided by GitHub user @xrun1
  # https://github.com/xddxdd/nur-packages/issues/31#issuecomment-1812591688
  fakeLsof = writeShellScriptBin "lsof" ''
    for arg in "$@"; do
      if [ -S "$arg" ]; then
        printf %s p
        echo '{"command": ["get_property", "pid"]}' |
          ${socat}/bin/socat - "UNIX-CONNECT:$arg" |
          ${jq}/bin/jq -Mr .data
        printf '\n'
      fi
    done
  '';

  libraries = [
    fakeLsof
    ffmpeg.bin
    glibc
    gnome.zenity
    libmediainfo
    libsForQt5.qtbase
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

  svp-dist = stdenv.mkDerivation rec {
    pname = "svp-dist";
    version = "4.5.210-2";
    src = fetchurl {
      url = "https://www.svp-team.com/files/svp4-linux.${version}.tar.bz2";
      sha256 = "sha256-dY9uQ9jzTHiN2XSnOrXtHD11IIJW6t9BUzGGQFfZ+yg=";
    };

    nativeBuildInputs = [p7zip patchelf];
    dontFixup = true;

    unpackPhase = ''
      tar xf ${src}
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
        mkdir -p "$out/share/icons/hicolor/''${SIZE}x''${SIZE}/apps"
        mv "$out/opt/svp-manager4-''${SIZE}.png" "$out/share/icons/hicolor/''${SIZE}x''${SIZE}/apps/svp-manager4.png"
      done
      rm -f $out/opt/{add,remove}-menuitem.sh
    '';
  };

  fhs = buildFHSEnv {
    name = "SVPManager";
    targetPkgs = pkgs: libraries;
    runScript = "${svp-dist}/opt/SVPManager";
    unshareUser = false;
    unshareIpc = false;
    unsharePid = false;
    unshareNet = false;
    unshareUts = false;
    unshareCgroup = false;
  };

  desktopFile = writeText "svp-manager4.desktop" ''
    [Desktop Entry]
    Version=1.0
    Encoding=UTF-8
    Name=SVP 4 Linux
    GenericName=Real time frame interpolation
    Type=Application
    Categories=Multimedia;AudioVideo;Player;Video;
    MimeType=video/x-msvideo;video/x-matroska;video/webm;video/mpeg;video/mp4;
    Terminal=false
    StartupNotify=true
    Exec=${fhs}/bin/SVPManager %f
    Icon=svp-manager4.png
  '';
in
  stdenv.mkDerivation {
    pname = "svp";
    inherit (svp-dist) version;
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin $out/share/applications
      ln -s ${fhs}/bin/SVPManager $out/bin/SVPManager
      ln -s ${desktopFile} $out/share/applications/svp-manager4.desktop
      ln -s ${svp-dist}/share/icons $out/share/icons
    '';

    passthru.mpv = mpvForSVP;

    meta = with lib; {
      description = "SmoothVideo Project 4 (SVP4) (MUST USE `packages.svp.mpv` IF YOU WANT TO LAUNCH MPV EXTERNALLY) (Packaging script adapted from https://aur.archlinux.org/packages/svp)";
      homepage = "https://www.svp-team.com/wiki/SVP:Linux";
      platforms = ["x86_64-linux"];
      license = licenses.unfree;
    };
  }
