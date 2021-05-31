{ stdenv
, file
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
, ncurses
, xz
, zlib
, runCommandNoCC
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
    ncurses
    fontconfig
    freetype
    glib
    libGL
    libffi
    libffi.dev
    libxkbcommon_7
    pulseaudio
    qt5.qtbase
    sqlite
    stdenv.cc.cc
    stdenv.cc.libc
    udev
    xorg.libX11
    xorg.libXrender
    xz
    zlib
  ];

  libPath = "${placeholder "out"}/share/talon/lib:"
    + "${placeholder "out"}/share/talon/resources/python/lib:"
    + "${placeholder "out"}/share/talon/resources/pypy/lib:"
    + "${placeholder "out"}/share/talon/resources/python/lib/python3.9/site-packages/numpy.libs:"
    + lib.makeLibraryPath buildInputs;

  pythonPath = "${placeholder "out"}/share/talon/resources/python/lib/python3.9/site-packages";

  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${libPath}"
    "--prefix PYTHONPATH : ${pythonPath}"
    "--set LC_NUMERIC C"
    "--unset PYTHONHOME"
  ];

  installPhase = ''
    runHook preInstall
  ''
  # Clean out unused stuff
  + ''
    # We don't use this script, so remove it to ensure that it's not run by
    # accident.
    rm run.sh

    # Use the Nix QT and QT plugins rather than the vendored talon ones.
    rm lib/libQt*
  ''
  # Copy Talon to the Nix store and patchelf
  + ''
    mkdir -p "$out/share/talon"
    cp --recursive --target-directory=$out/share/talon *

    # Tell talon where to find glibc
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath $libPath \
      $out/share/talon/talon
  ''
  # Setup a bin dir
  + ''
    mkdir -p "$out/bin"
    ln -s "$out/share/talon/talon" "$out/bin/talon"
  ''
  # Add a wrapped talon repl too
  # FIXME: This does not work due to PYTHONHOME issues?
  # + ''
  #   sed 's|^exec .*|exec -a "$0" $out/share/talon/resources/python/bin/python3 "'$out'/share/talon/resources/repl.py"|' \
  #      "$out/bin/talon" \
  #      > "$out/bin/repl"

  #   chmod +x "$out/bin/repl"
  # ''
  + ''
    runHook postInstall
  '';

  meta = with lib; {
    description = "";
    homepage = "https://talonvoice.com";
    license = licenses.unfree; # https://talonvoice.com/EULA.txt
    maintainer = maintainers.bhipple;
  };
}
