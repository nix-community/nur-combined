{
  lib,
  stdenv,
  fetchurl,
  cmake,
  unzip,
  ncurses5,
  SDL,
  SDL_mixer,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ascii-dash";
  version = "1.3";

  src = fetchurl {
    url = "mirror://sourceforge/ascii-dash/ASCII-DASH-${finalAttrs.version}.zip";
    hash = "sha256-38wBq067aIq9wr34WIP6Kg9LLnc8/2xV9Q+LkmflB5U=";
  };

  postPatch = ''
    substituteInPlace ascii-gfx/main.cpp \
      --replace-fail "boing.wav" "$out/share/ascii-dash/sounds/boing.wav"
    substituteInPlace dash/dash.cpp \
      --replace-fail "sounds/" "$out/share/ascii-dash/sounds/"
    substituteInPlace dash/dash_physics.cpp \
      --replace-fail "sounds/" "$out/share/ascii-dash/sounds/"
    substituteInPlace main.cpp \
      --replace-fail "data/" "$out/share/ascii-dash/data/"
  '';

  nativeBuildInputs = [
    cmake
    unzip
  ];

  buildInputs = [
    ncurses5
    SDL
    SDL_mixer
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-error=mismatched-new-delete"
  ]
  ++ lib.optional stdenv.cc.isGNU "-Wno-error=stringop-truncation";

  installPhase = ''
    install -Dm755 main $out/bin/ascii-dash

    mkdir -p $out/share/ascii-dash
    cp -r ../{data,sounds} $out/share/ascii-dash
  '';

  meta = {
    description = "Remake of BOULDER DASH with NCurses";
    homepage = "https://ascii-dash.sourceforge.io/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "ascii-dash";
  };
})
