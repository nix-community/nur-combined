{
  fetchFromGitHub,
  unstableGitUpdater,
  lib,
  stdenv,
  cmake,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "liboqs";
  version = "0-unstable-2026-11-16";

  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "liboqs";
    rev = "395d2aa8c7a0cf578b8086c6853baca9df56be5b";
    hash = "sha256-h7ENg8IXL9KwxofvM4uINvZ7bwBE9owxcrZuNoQxZmg=";
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
