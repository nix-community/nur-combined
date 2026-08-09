{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gpgme,
  libgcrypt,
  curl,
  squashfsTools,
  desktop-file-utils,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "appimagetool";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "AppImage";
    repo = "appimagetool";
    tag = finalAttrs.version;
    hash = "sha256-QQF2Z4U3MyhNZfAB5/zIL3mFt2ngKpI+rCD0pb6Jml4=";
  };

  postPatch = ''
    substituteInPlace src/appimagetool.c \
      --replace-fail '"mksquashfs"' '"${lib.getExe squashfsTools}"' \
      --replace-fail '"desktop-file-validate"' '"${lib.getExe' desktop-file-utils "desktop-file-validate"}"' \
      --replace-fail "RELEASE_NAME, GIT_VERSION, BUILD_NUMBER, BUILD_DATE" '"Nixpkgs", "${finalAttrs.version}", "1", "-"'
  '';

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    gpgme
    libgcrypt
    curl
  ];

  cmakeFlags = [
    (lib.cmakeFeature "GIT_VERSION" finalAttrs.version)
  ];

  preBuild = ''
    cmakeFlags+=("-DDATE:STRING=$SOURCE_DATE_EPOCH")
  '';
})
