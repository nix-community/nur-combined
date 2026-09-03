{
  fetchFromGitHub,
  unstableGitUpdater,
  lib,
  stdenv,
  cmake,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "liboqs";
  version = "0-unstable-2026-09-03";

  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "liboqs";
    rev = "c27c88b76473f67a8072ce5b66874d172287ff96";
    hash = "sha256-T9PcrGinJmnwn0KDI7iRwwLalCBSz0uy6OzdBjShlrs=";
  };

  enableParallelBuilding = true;
  dontFixCmake = true;

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DOQS_BUILD_ONLY_LIB=1"
    "-DOQS_USE_OPENSSL=OFF"
  ]
  ++ (
    if stdenv.hostPlatform.isx86_64 then
      [ "-DOQS_DIST_BUILD=ON" ]
    else
      [
        # Disable OQS_DIST_BUILD or it fails with some "target specific option mismatch" error
        "-DOQS_DIST_BUILD=OFF"
        "-DOQS_OPT_TARGET=generic"
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
