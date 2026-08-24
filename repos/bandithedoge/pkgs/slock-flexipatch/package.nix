{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  libx11,
  libxcrypt,
  libxext,
  libxrandr,
}:
stdenv.mkDerivation {
  pname = "slock-flexipatch";
  version = "0-unstable-2026-08-17";
  src = fetchFromGitHub {
    owner = "bakkeby";
    repo = "slock-flexipatch";
    rev = "f387ce4caf0cbde7707ba55da7cabd79c7e23c29";
    hash = "sha256-mZLi7MoXnY7hUdIpQdlQV95DbFPVndSXSPXYi203a+w=";
  };

  buildInputs = [
    libx11
    libxcrypt
    libxext
    libxrandr
  ];

  installFlags = [ "PREFIX=$(out)" ];

  postPatch = "sed -i '/chmod u+s/d' Makefile";

  enableParallelBuilding = true;

  makeFlags = [ "CC:=$(CC)" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "An slock build with preprocessor directives to decide which patches to include during build time";
    homepage = "https://github.com/bakkeby/slock-flexipatch";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "slock";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
