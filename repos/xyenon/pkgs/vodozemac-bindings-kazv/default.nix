{
  fetchFromGitLab,
  rustPlatform,
  unstableGitUpdater,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "vodozemac-bindings-kazv";
  version = "0-unstable-2024-08-23";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "vodozemac-bindings";
    rev = "ec4d3c147b50dbaf2b65490c48573d59c5012805";
    hash = "sha256-pLDwjZEfmPVGBhltzFnZZgtGCN0RSYpfCZlQktDT0X8=";
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
