{
  fetchFromGitLab,
  rustPlatform,
  perl,
  unstableGitUpdater,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "vodozemac-bindings-kazv";
  version = "0.1.0-unstable-2024-11-14";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "vodozemac-bindings";
    rev = "80bbd9b9db69a7bc735cacde17d66cf82639b62e";
    hash = "sha256-l9PnLNfhbPxYEIF+7TJ3KuVAKR8iNoROH6zBT0if7fU=";
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
