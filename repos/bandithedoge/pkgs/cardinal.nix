{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.cardinal) src pname version;

  nativeBuildInputs = with pkgs; [pkg-config];

  buildInputs = with pkgs; [
    SDL2
    alsa-lib
    dbus
    freetype
    glib
    jansson
    libGL
    libarchive
    liblo
    libsamplerate
    mesa
    python3
    speexdsp
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXrandr
  ];

  prePatch = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  enableParallelBuilding = true;

  makeFlags = ["SYSDEPS=true" "PREFIX=$(out)"];

  hardeningDisable = ["format"];

  meta = {
    inherit (pkgs.cardinal.meta) description homepage license platforms;
  };
}
