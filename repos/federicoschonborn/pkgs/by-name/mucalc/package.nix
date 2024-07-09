{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  muparser,
  readline,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mucalc";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "marlam";
    repo = "mucalc-mirror";
    rev = "mucalc-${finalAttrs.version}";
    hash = "sha256-qXqe9U7y3YrzSeJKgW53vkdNpPcAmxysxzT7SIlSzMo=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    muparser
    readline
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "mucalc-(.*)"
    ];
  };

  meta = {
    mainProgram = "mucalc";
    description = "A convenient calculator for the command line";
    homepage = "https://marlam.de/mucalc/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
