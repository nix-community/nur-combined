{
  fetchgit,
  rustPlatform,
  perl,
  nix-update-script,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "vodozemac-bindings-kazv";
  version = "0.2.1-unstable-2025-12-01";

  src = fetchgit {
    url = "https://r.lily-is.land/the-kazv-project/vodozemac-bindings.git";
    rev = "3a3b85bf3043ffa43bd6bc70e571b455a276e749";
    hash = "sha256-j6s+O3s6xSIZ+6aWI3itVwL4OU4qhoXos1R2NMBrJdo=";
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

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Language bindings for vodozemac";
    homepage = "https://r.lily-is.land/the-kazv-project/vodozemac-bindings";
    license = licenses.asl20;
    maintainers = with maintainers; [ xyenon ];
  };
}
