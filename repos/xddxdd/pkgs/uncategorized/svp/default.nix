{ stdenv
, bubblewrap
, fetchurl
, ffmpeg
, glibc
, gnome
, lib
, libmediainfo
, libsForQt5
, libusb1
, lsof
, makeWrapper
, mpv-unwrapped
, nvidia_x11 ? null
, ocl-icd
, p7zip
, patchelf
, vapoursynth
, wrapMpv
, writeShellScript
, writeText
, xdg-utils
, xorg
, ...
}:

################################################################################
# Based on svp package from AUR:
# https://aur.archlinux.org/packages/svp
################################################################################

let
  mpvForSVP = wrapMpv
    (mpv-unwrapped.override {
      vapoursynthSupport = true;
    })
    {
      extraMakeWrapperArgs = lib.optionals (nvidia_x11 != null) [
        "--prefix"
        "LD_LIBRARY_PATH"
        ":"
        "${lib.makeLibraryPath [ nvidia_x11 ]}"
      ];
    };

  libPath = lib.makeLibraryPath [
    libsForQt5.qtbase
    libsForQt5.qtdeclarative
    libsForQt5.qtscript
    libsForQt5.qtsvg
    libmediainfo
    libusb1
    xorg.libX11
    stdenv.cc.cc.lib
    ocl-icd
    vapoursynth
  ];

  execPath = lib.makeBinPath [
    ffmpeg.bin
    gnome.zenity
    lsof
    xdg-utils
  ];

  svp-dist = stdenv.mkDerivation rec {
    pname = "svp-dist";
    version = "4.5.210";
    src = fetchurl {
      url = "https://www.svp-team.com/files/svp4-linux.${version}-1.tar.bz2";
      sha256 = "10q8r401wg81vanwxd7v07qrh3w70gdhgv5vmvymai0flndm63cl";
    };

    nativeBuildInputs = [ p7zip patchelf ];
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

  startScript = writeShellScript "SVPManager" ''
    blacklist=(/nix /dev /usr /lib /lib64 /proc)

    declare -a auto_mounts
    # loop through all directories in the root
    for dir in /*; do
      # if it is a directory and it is not in the blacklist
      if [[ -d "$dir" ]] && [[ ! "''${blacklist[@]}" =~ "$dir" ]]; then
        # add it to the mount list
        auto_mounts+=(--bind "$dir" "$dir")
      fi
    done

    cmd=(
      ${bubblewrap}/bin/bwrap
      --dev-bind /dev /dev
      --chdir "$(pwd)"
      --die-with-parent
      --ro-bind /nix /nix
      --proc /proc
      --bind ${glibc}/lib /lib
      --bind ${glibc}/lib /lib64
      --bind /usr/bin/env /usr/bin/env
      --bind ${ffmpeg.bin}/bin/ffmpeg /usr/bin/ffmpeg
      --bind ${lsof}/bin/lsof /usr/bin/lsof
      --setenv PATH "${execPath}:''${PATH}"
      --setenv LD_LIBRARY_PATH "${libPath}:''${LD_LIBRARY_PATH}"
      --symlink ${mpvForSVP}/bin/mpv /usr/bin/mpv
      "''${auto_mounts[@]}"
      # /bin/sh
      ${svp-dist}/opt/SVPManager "$@"
    )
    exec "''${cmd[@]}"
  '';

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
    Exec=${startScript} %f
    Icon=svp-manager4.png
  '';
in
stdenv.mkDerivation {
  pname = "svp";
  inherit (svp-dist) version;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin $out/share/applications
    ln -s ${startScript} $out/bin/SVPManager
    ln -s ${desktopFile} $out/share/applications/svp-manager4.desktop
    ln -s ${svp-dist}/share/icons $out/share/icons
  '';

  meta = with lib; {
    description = "SmoothVideo Project 4 (SVP4)";
    homepage = "https://www.svp-team.com/wiki/SVP:Linux";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
  };
}
