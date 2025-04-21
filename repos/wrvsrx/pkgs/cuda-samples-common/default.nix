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
    sha256 = "sha256-Ba0Fi0v/sQ+1iJ4mslgyIAE+oK5KO0lMoTQCC91vpiA=";
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
