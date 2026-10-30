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
  version = "0-unstable-2026-10-30";
  src = fetchFromGitHub {
    owner = "bakkeby";
    repo = "dwm-flexipatch";
    rev = "f2fa97e18742c46847780c3342f07c7293ec1bb2";
    hash = "sha256-QRWNxpsi/85lFMEkyO4xWV30eaeYuQJMxGX5Qtj8jBA=";
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
