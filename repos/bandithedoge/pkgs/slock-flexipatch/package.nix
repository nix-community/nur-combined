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
  version = "0-unstable-2026-09-14";
  src = fetchFromGitHub {
    owner = "bakkeby";
    repo = "slock-flexipatch";
    rev = "3c89626a09a543de104bd766d471f9e16e4e4002";
    hash = "sha256-l1tfnYkBHch0b0dUOE9LoX4P9iJdHXwlVL6JH7Sq7As=";
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
