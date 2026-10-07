{
  fetchFromGitHub,
  unstableGitUpdater,
  lib,
  stdenv,
  cmake,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "liboqs";
  version = "0-unstable-2026-10-06";

  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "liboqs";
    rev = "aeaac6eeb1ac84c1bc4439d9aae5267ef9832ef0";
    hash = "sha256-WiglDtRD84K3f8HsLwtx6tfRWFt77U0LDXgu20tCT5E=";
  };

  enableParallelBuilding = true;
  dontFixCmake = true;

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "OQS_BUILD_ONLY_LIB" true)
    (lib.cmakeBool "OQS_USE_OPENSSL" false)
  ]
  ++ (
    if stdenv.hostPlatform.isx86_64 then
      [ (lib.cmakeBool "OQS_DIST_BUILD" true) ]
    else
      [
        # Disable OQS_DIST_BUILD or it fails with some "target specific option mismatch" error
        (lib.cmakeBool "OQS_DIST_BUILD" false)
        (lib.cmakeFeature "OQS_OPT_TARGET" "generic")
      ]
  );

  postFixup = ''
    sed -i "s#//#/#g" $out/lib/pkgconfig/liboqs.pc
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/open-quantum-safe/liboqs";
    hardcodeZeroVersion = true;
  };

  meta = {
    changelog = "https://github.com/open-quantum-safe/liboqs/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "C library for prototyping and experimenting with quantum-resistant cryptography";
    homepage = "https://openquantumsafe.org";
    license = with lib.licenses; [ mit ];
  };
})
