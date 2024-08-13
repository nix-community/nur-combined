{
  fetchFromGitLab,
  rustPlatform,
  unstableGitUpdater,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "vodozemac-bindings-kazv";
  version = "0-unstable-2024-08-07";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "vodozemac-bindings";
    rev = "bcf7910f85018e5d02ad6b64a331495115a8bfb2";
    hash = "sha256-EVZpsvQrQ+YHSJdS8InnfcFrRf6fxwA6atl2h9Wgc8g=";
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
