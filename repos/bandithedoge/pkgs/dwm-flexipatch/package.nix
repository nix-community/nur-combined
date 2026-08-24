{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  libx11,
  libxft,
  libxinerama,
}:
stdenv.mkDerivation {
  pname = "dwm-flexipatch";
  version = "0-unstable-2026-07-06";
  src = fetchFromGitHub {
    owner = "bakkeby";
    repo = "dwm-flexipatch";
    rev = "4c963b33681b277a0ff4d3bf39a27b2feab68950";
    hash = "sha256-xYspDyPPBqTkO4SrB2+u1mUPTbWI52asXWjU0NFd2AU=";
  };

  buildInputs = [
    libx11
    libxinerama
    libxft
  ];

  prePatch = ''
    sed -i "s@/usr/local@$out@" config.mk
  '';

  enableParallelBuilding = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "A dwm build with preprocessor directives to decide which patches to include during build time";
    homepage = "https://github.com/bakkeby/dwm-flexipatch";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dwm";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
