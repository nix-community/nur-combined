{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  muparser,
  readline,
  versionCheckHook,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mucalc";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "marlam";
    repo = "mucalc";
    rev = "refs/tags/mucalc-${finalAttrs.version}";
    hash = "sha256-6nvP7aVWF66ze/bANHujWUkqpCdvocD4eKPLXrg1cYM=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    muparser
    readline
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  strictDeps = true;

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
    platforms = lib.platforms.unix;
    # mucalc.cpp:382:12: error: no matching member function for call to 'DefineFun'
    broken = stdenv.hostPlatform.isDarwin;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
