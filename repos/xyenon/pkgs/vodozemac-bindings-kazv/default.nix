{
  rustPlatform,
  fetchFromForgejo,
  perl,
  nix-update-script,
  lib,
}:

rustPlatform.buildRustPackage {
  __structuredAttrs = true;

  pname = "vodozemac-bindings-kazv";
  version = "0.2.1-unstable-2026-07-12";
  src = fetchFromForgejo {
    domain = "r.lily-is.land";
    forceFetchGit = true;
    owner = "the-kazv-project";
    repo = "vodozemac-bindings";
    rev = "83d116679c6e06af957466437cca1fe1e63658a3";
    hash = "sha256-LRA8Yoez+RJNvrP5AwA0UEeJlpgtLFqyW0ZHXtx85OM=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "vodozemac-0.9.0" = "sha256-2wJbIJd4Qa+EdVwVlmenjKq4gtqmz04EcHk7Van5Xhs=";
    };
  };

  nativeBuildInputs = [ perl ];

  buildPhase = ''
    runHook preBuild
    make -C cpp
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make -C cpp "PREFIX=$out" install
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--version-regex=^v(.*)$"
    ];
  };

  meta = {
    description = "Language bindings for vodozemac";
    homepage = "https://r.lily-is.land/the-kazv-project/vodozemac-bindings";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    platforms = lib.platforms.linux;
  };
}
