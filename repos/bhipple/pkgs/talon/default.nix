{ stdenv
, fetchurl
, lib
, requireFile
, makeWrapper
, alacritty
, bzip2
, dbus
, fontconfig
, freetype
, glib
, libGL
, libpulseaudio
, libxkbcommon
, openssl
, rustc
, snixembed
, sqlite
, udev
, xorg
, xz
, zlib
}:
stdenv.mkDerivation rec {
  pname = "talon";
  version = "115-0.4.0-1050-3c4a";
  src = ./talon-linux-115-0.4.0-1050-3c4a.tar.xz;
  preferLocalBuild = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    bzip2
    dbus
    fontconfig
    freetype
    glib
    libGL
    libpulseaudio
    libxkbcommon
    openssl
    rustc
    snixembed
    sqlite
    stdenv.cc.cc
    stdenv.cc.libc
    udev
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libxcb
    xz
    zlib
  ];
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = let
    libPath = lib.makeLibraryPath buildInputs;
    binPath = lib.makeBinPath [ alacritty ];
  in ''
    runHook preInstall
    # Copy Talon to the Nix store
    mkdir -p "$out"
    cp --recursive --target-directory=$out *
    # We don't use this script, so remove it to ensure that it's not run by
    # accident.
    rm $out/run.sh
    # Tell talon where to find glibc
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/talon
    # Replicate 'run.sh' and add library path

    wrapProgram "$out/talon" \
      --unset QT_AUTO_SCREEN_SCALE_FACTOR \
      --unset QT_SCALE_FACTOR \
      --set   LC_NUMERIC C \
      --set   QT_PLUGIN_PATH "$out/lib/plugins" \
      --set   LD_LIBRARY_PATH "$out/lib:$out/resources/python/lib:$out/resources/pypy/lib:${libPath}" \
      --prefix PATH : "${binPath}"

    # The libbz2 derivation in Nix doesn't provide the right .so filename, so
    # we fake it by adding a link in the lib/ directory
    (
      cd "$out/lib"
      ln -s ${bzip2.out}/lib/libbz2.so.1 libbz2.so.1.0
    )

    mkdir $out/bin
    (
      cd $out/bin && ln -s ../talon
    )

    runHook postInstall
  '';
}
