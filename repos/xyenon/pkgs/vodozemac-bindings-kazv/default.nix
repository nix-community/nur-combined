{
  fetchFromGitLab,
  rustPlatform,
  perl,
  unstableGitUpdater,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "vodozemac-bindings-kazv";
  version = "0.1.0-unstable-2024-09-26";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "vodozemac-bindings";
    rev = "f3a92709c0be6bd886a32dd7b4e5d04054e75391";
    hash = "sha256-bZgQ4gMVvZLOlDNe9XKcrZcUnr5osskiVXmy4FwFqaA=";
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

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    description = "Language bindings for vodozemac";
    homepage = "https://lily-is.land/kazv/vodozemac-bindings";
    license = licenses.asl20;
    maintainers = with maintainers; [ xyenon ];
  };
}
