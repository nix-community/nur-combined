{ stdenv
, fetchurl
, lib
, requireFile
, makeWrapper
, bzip2
, dbus
, fontconfig
, freetype
, glib
, libGL
, libxkbcommon_7
, sqlite
, udev
, xorg
, xz
, zlib
, libpulseaudio
, alacritty
}:
let
  # See README.md
  srcs =
    if builtins.pathExists ./beta-src.nix
    then import ./beta-src.nix
    else import ./src.nix;
in
stdenv.mkDerivation rec {
  pname = "talon";
  inherit (srcs) version;
  src = fetchurl {
    inherit (srcs) url sha256;
  };
  preferLocalBuild = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    # qt5.wrapQtAppsHook
    stdenv.cc.cc
    stdenv.cc.libc
    bzip2
    dbus
    fontconfig
    freetype
    glib
    libGL
    libxkbcommon_7
    sqlite
    udev
    xorg.libX11
    xorg.libSM
    xorg.libICE
    xorg.libXrender
    xorg.libxcb
    xz
    zlib
    libpulseaudio
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
    runHook postInstall

    mkdir $out/bin
    (
      cd $out/bin && ln -s ../talon talon
    )
  '';
}
