{ callPackage, buildFHSUserEnv }:

let
  runescape-launcher = callPackage ./default.nix { };
in
buildFHSUserEnv rec {
  name = runescape-launcher.pname;
  inherit (runescape-launcher) meta;

  targetPkgs = pkgs: with pkgs; [
    # Libraries, found with:
    # > patchelf --print-needed $out/share/games/runescape-launcher/runescape
    cairo
    gdk_pixbuf
    glib
    glibc
    gtk2-x11
    libcap
    openssl
    pango
    xlibs.libSM
    xlibs.libX11
    xlibs.libXxf86vm
    zlib

    # Libraries, found with:
    # > patchelf --print-needed ~/Jagex/launcher/rs2client
    glibc
    libGL
    openssl
    SDL2
    zlib

    # Binaries, found with:
    # > strings $out/share/games/runescape-launcher/runescape | grep /bin
    # > strings ~/Jagex/launcher/rs2client | grep /bin
    xdg_utils
  ];

  extraInstallCommands = ''
    mkdir -p "$out"
    ln -s ${runescape-launcher}/share "$out"
  '';

  runScript = "${runescape-launcher}/bin/${name}";

  passthru.unwrapped = runescape-launcher;
}
