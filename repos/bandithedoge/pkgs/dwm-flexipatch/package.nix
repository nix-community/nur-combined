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
  version = "0-unstable-2026-11-25";
  src = fetchFromGitHub {
    owner = "bakkeby";
    repo = "dwm-flexipatch";
    rev = "2b8821250921c798a0287a5a238f497dbf455a42";
    hash = "sha256-hgvBLU0mS+InaqMbCpk7lRDJ2KBKs3rMfbmuNNRrsYo=";
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
