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
  version = "1.0.0-unstable-2026-08-23";
  src = fetchFromForgejo {
    domain = "r.lily-is.land";
    forceFetchGit = true;
    owner = "the-kazv-project";
    repo = "vodozemac-bindings";
    rev = "4a22383c32516205d2b4d545fdc95d451acc2818";
    hash = "sha256-UZgao4FZ8CAKYwtS5bMRakj4HQTrTXLmpLDhqfM695I=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "vodozemac-0.10.0" = "sha256-nAeQNGc7zIzickS4nCNTxUC+IkLI2J7JyfHXkTeylEg=";
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
