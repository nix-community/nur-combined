{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  fontconfig,
  freetype,
  libx11,
  libxft,
  ncurses,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "st-flexipatch";
  version = "371878-unstable-2026-10-30";
  src = fetchFromGitHub {
    owner = "bakkeby";
    repo = "st-flexipatch";
    rev = "9c733c4b78bf3a145f25a737beac38c52ad63b76";
    hash = "sha256-5m9LivxQJtNbzYwJbNSI4L57lsSgcIRi4WnBjfFkxBA=";
  };

  nativeBuildInputs = [
    pkg-config
    ncurses
    fontconfig
    freetype
  ];

  buildInputs = [
    libx11
    libxft
  ];

  strictDeps = true;

  enableParallelBuilding = true;

  makeFlags = [
    "PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"
  ];

  postPatch = lib.optionalString stdenv.targetPlatform.isDarwin ''
    substituteInPlace config.mk --replace "-lrt" ""
  '';

  preInstall = ''
    export TERMINFO=$out/share/terminfo
  '';

  installFlags = [ "PREFIX=$(out)" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "An st build with preprocessor directives to decide which patches to include during build time";
    homepage = "https://github.com/bakkeby/st-flexipatch";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "st";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
