{
  lib,
  stdenv,
  cmake,
  python3,
  spirvCrossSrc,
}:

# Steamac pins utmapp/SPIRV-Cross and applies its own patch series on top.
# MoltenVK links these libraries directly, so the patched source (not the
# nixpkgs spirv-cross) has to be built.
stdenv.mkDerivation (finalAttrs: {
  pname = "spirv-cross-steamac";
  # utmapp/SPIRV-Cross @ 939b40b33a44443c404c4078823c406e3c94866f
  version = "0-unstable-2026-02-21";

  src = spirvCrossSrc;

  nativeBuildInputs = [
    cmake
    python3
  ];

  cmakeFlags = [
    (lib.cmakeBool "SPIRV_CROSS_SHARED" true)
    "-DSPIRV_CROSS_ENABLE_TESTS=OFF"
    "-DSPIRV_CROSS_CLI=OFF"
  ];

  # SPIRV-Cross's CMake install joins ${prefix} with absolute paths.
  postFixup = ''
    substituteInPlace $out/lib/pkgconfig/*.pc \
      --replace '=''${prefix}//' '=/'
  '';

  meta = {
    description = "SPIRV-Cross fork patched for Steamac's MoltenVK";
    homepage = "https://github.com/utmapp/SPIRV-Cross";
    license = lib.licenses.asl20;
    platforms = lib.platforms.darwin;
  };
})
