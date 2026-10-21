{
  fetchFromGitHub,
  unstableGitUpdater,
  lib,
  stdenv,
  cmake,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "liboqs";
  version = "0-unstable-2026-10-21";

  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "liboqs";
    rev = "c4d14c906f825a18f0713bab95d40cd4dc7fe629";
    hash = "sha256-MIQJFZiGvsZtOqNZLbB0zHkCn2eoKsB3dUdece3LvEE=";
  };
  __structuredAttrs = true;
  strictDeps = true;

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
