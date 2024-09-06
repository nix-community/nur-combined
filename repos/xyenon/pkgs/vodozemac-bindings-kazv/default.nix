{
  fetchFromGitLab,
  rustPlatform,
  unstableGitUpdater,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "vodozemac-bindings-kazv";
  version = "0-unstable-2024-08-30";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "vodozemac-bindings";
    rev = "9a438c5926a405bd895071f15bf8c4d8c2462376";
    hash = "sha256-z84NbQyM34U+2ya4+D+awGEH9/6lu8E0xpZIOYz6b4s=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} ./Cargo.lock
  '';

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
