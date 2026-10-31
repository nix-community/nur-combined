# Host unit tests and fuzz smoke runs for the firmware's own components. They
# compile the production sources of the pinned trees with ASan/UBSan; this is
# not a NixOS VM test, but it is surfaced and built as a flake check the same way.
{
  lib,
  clangStdenv,
  cmake,
  ninja,
  pkg-config,
  cmocka,
  llvmPackages,
  edk2-cix-codgician,
}:

clangStdenv.mkDerivation {
  pname = "edk2-cix-codgician-host-tests";
  inherit (edk2-cix-codgician) version;

  dontUnpack = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];
  # compiler-rt provides libFuzzer and the sanitizer runtimes.
  buildInputs = [
    cmocka
    llvmPackages.compiler-rt
  ];
  # Sanitizer builds conflict with nixpkgs' fortify/stack hardening flags.
  hardeningDisable = [ "all" ];
  dontUseCmakeConfigure = true;

  # The harness locates edk2 next to edk2-platforms.
  buildPhase = ''
    runHook preBuild
    mkdir workspace
    ln -s ${edk2-cix-codgician.edk2} workspace/edk2
    ln -s ${edk2-cix-codgician.edk2Platforms} workspace/edk2-platforms
    cmake -S workspace/edk2-platforms/Platform/CIX/Sky1/Test/HostTest -B build -G Ninja
    cmake --build build
    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ctest --test-dir build --output-on-failure -j "$NIX_BUILD_CORES"
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    ctest --test-dir build -N > "$out/tests"
    runHook postInstall
  '';

  meta = {
    description = "Host unit tests for edk2-cix-codgician";
    license = lib.licenses.bsd2Patent;
    inherit (edk2-cix-codgician.meta) platforms;
  };
}
