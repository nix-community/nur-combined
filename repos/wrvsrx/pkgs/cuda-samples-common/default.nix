{
  lib,
  meson,
  cmake,
  ninja,
  pkg-config,
  haskellPackages,
  cudaPackages,
  substituteAll,
  source,
}:
let
  version = lib.removePrefix "v" source.version;
in
cudaPackages.backendStdenv.mkDerivation {
  pname = "cuda-samples-common";
  inherit (source) src;
  inherit version;
  patches = [
    (substituteAll {
      src = ./meson.patch;
      inherit version;
    })
    ./cpp20.patch
  ];
  generateMesonPhase = ''
    runghc Main > meson.build
  '';
  preConfigurePhases = [ "generateMesonPhase" ];
  nativeBuildInputs = [
    meson
    cmake
    ninja
    pkg-config
    (haskellPackages.ghcWithPackages (
      ps: with ps; [
        raw-strings-qq
        extra
      ]
    ))
  ];
}
