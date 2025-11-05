{
  meson,
  cmake,
  ninja,
  pkg-config,
  haskellPackages,
  cudaPackages,
  replaceVars,
}:
cudaPackages.backendStdenv.mkDerivation (
  finalAttrs:
  let
    generate-meson-script = replaceVars ./meson.hs { inherit (finalAttrs) version; };
  in
  {
    pname = "cuda-samples-common";
    inherit (cudaPackages.cuda-samples) version src;
    patches = [
      ./cpp20.patch
    ];
    generateMesonPhase = ''
      runghc ${generate-meson-script} > meson.build
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
)
