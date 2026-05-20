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
  version = "0.2.1-unstable-2026-04-04";
  src = fetchFromForgejo {
    domain = "r.lily-is.land";
    forceFetchGit = true;
    owner = "the-kazv-project";
    repo = "vodozemac-bindings";
    rev = "3cf688afc0c8d6fe77e3eb126888a5ddd191f23b";
    hash = "sha256-OWYLUgqf2ThNF2wbbrzlHsPmDpWbltwNEE4qY3QTZI0=";
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
