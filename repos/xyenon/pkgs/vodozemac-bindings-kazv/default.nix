{
  fetchFromGitLab,
  rustPlatform,
  unstableGitUpdater,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "vodozemac-bindings-kazv";
  version = "0-unstable-2024-09-15";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "vodozemac-bindings";
    rev = "5f99034d7e6ac0098461e044468834608fd57c26";
    hash = "sha256-84rZLpKeHEdCtpdu/WrL50xuOpCD9LIqAK1OZRZahgw=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "vodozemac-0.7.0" = "sha256-MkPtoEMT0KQQlmx00WcnpoEtgN/tmSNwZYPXUBqv454=";
    };
  };

  postInstall = ''
    mkdir -p $out/include
    cp $releaseDir/../cxxbridge/vodozemac/src/lib.rs.h $out/include/vodozemac.h
  '';

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    description = "Language bindings for vodozemac";
    homepage = "https://lily-is.land/kazv/vodozemac-bindings";
    license = licenses.asl20;
    maintainers = with maintainers; [ xyenon ];
  };
}
