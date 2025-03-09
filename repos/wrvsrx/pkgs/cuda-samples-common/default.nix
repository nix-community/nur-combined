{
  meson,
  cmake,
  ninja,
  pkg-config,
  haskellPackages,
  cudaPackages,
  substituteAll,
  fetchFromGitHub,
}:
cudaPackages.backendStdenv.mkDerivation (finalAttrs: {
  pname = "cuda-samples-common";
  inherit (cudaPackages.cudatoolkit) version;
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "cuda-samples";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-D+kP1OEJ4zR/9wKL+jjAv3TRv1IdX39mhZ1MvobX6F0=";
  };
  patches = [
    (substituteAll {
      src = ./meson.patch;
      inherit (finalAttrs) version;
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
})
