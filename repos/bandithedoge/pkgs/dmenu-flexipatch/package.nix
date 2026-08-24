{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  libx11,
  libxft,
  libxinerama,
  zlib,
}:
stdenv.mkDerivation {
  pname = "dmenu-flexipatch";
  version = "0-unstable-2026-03-10";
  src = fetchFromGitHub {
    owner = "bakkeby";
    repo = "dmenu-flexipatch";
    rev = "c59af646f2d8ccbc31f799111b0ff7a1282efa63";
    hash = "sha256-eQp1HJ64GJ1Xm6cIAWnaO39A2doL8RAEL4m09paTMjw=";
  };

  buildInputs = [
    libx11
    libxft
    libxinerama
    zlib
  ];

  preConfigure = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
  '';

  enableParallelBuilding = true;

  makeFlags = [ "CC:=$(CC)" ];

  postPatch = ''
    sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
    sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "A dmenu build with preprocessor directives to decide which patches to include during build time";
    homepage = "https://github.com/bakkeby/dmenu-flexipatch";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dmenu";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
