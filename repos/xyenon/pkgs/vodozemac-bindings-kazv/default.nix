{
  fetchFromGitLab,
  rustPlatform,
  perl,
  nix-update-script,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "vodozemac-bindings-kazv";
  version = "0.2.0-unstable-2024-11-17";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "vodozemac-bindings";
    rev = "73c6527f3ae698bd74698152cd640840aaa64220";
    hash = "sha256-DOc5GxMgpecJeQtkDSwvGD+bOyCZ8XRQ/uC/RAnKQv4=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "vodozemac-0.7.0" = "sha256-MkPtoEMT0KQQlmx00WcnpoEtgN/tmSNwZYPXUBqv454=";
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
    homepage = "https://lily-is.land/kazv/vodozemac-bindings";
    license = licenses.asl20;
    maintainers = with maintainers; [ xyenon ];
  };
}
