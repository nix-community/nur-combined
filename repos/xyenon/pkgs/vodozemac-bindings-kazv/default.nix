{
  fetchgit,
  rustPlatform,
  perl,
  nix-update-script,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "vodozemac-bindings-kazv";
  version = "0.2.0-unstable-2025-10-07";

  src = fetchgit {
    url = "https://r.lily-is.land/the-kazv-project/vodozemac-bindings.git";
    rev = "0de85a7b18499baca101a2eabf80697e49f46aa7";
    hash = "sha256-TAif6Pex0uA45EuYoI9ozProi8vnPZw/dXjdivzD9U4=";
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
