{ stdenv
, dbus
, fetchurl
, fontconfig
, freetype
, glib
, lib
, libGL
, libffi
, libxkbcommon_7
, pulseaudio
, qt5
, sqlite
, udev
, xorg
, xz
, zlib
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

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    dbus
    fontconfig
    freetype
    glib
    libGL
    libffi
    libxkbcommon_7
    pulseaudio
    sqlite
    stdenv.cc.cc
    stdenv.cc.libc
    udev
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXrender
    xorg.libxcb
    xz
    zlib
  ];

  libPath = "${placeholder "out"}/lib:"
    + "${placeholder "out"}/resources/python/lib:"
    + "${placeholder "out"}/resources/python/lib/python3.9/site-packages/numpy.libs:"
    + lib.makeLibraryPath buildInputs;

  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${libPath}"
    "--set LC_NUMERIC C"
  ];

  installPhase = ''
    runHook preInstall
  ''
  # Clean out unused stuff
  + ''
    rm run.sh
  ''
  # Copy Talon to the Nix store and patchelf
  + ''
    mkdir -p $out
    cp --recursive --target-directory=$out *

    # Tell talon where to find glibc
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath $libPath \
      $out/talon
  ''
  # Setup a bin dir
  + ''
    mkdir -p "$out/bin"
    ln -s "$out/talon" "$out/bin/talon"
  ''
  + ''
    runHook postInstall
  '';

  meta = with lib; {
    description = "Powerful hands-free input";
    homepage = "https://talonvoice.com";
    license = licenses.unfree; # https://talonvoice.com/EULA.txt
    maintainer = maintainers.bhipple;
    platforms = platforms.linux;
  };
}
