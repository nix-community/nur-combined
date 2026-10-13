{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  cmake,
  pkg-config,
  oniguruma,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qsp-lib";
  version = "5.9.5-unstable-2026-10-13";
  src = fetchFromGitHub {
    owner = "QSPFoundation";
    repo = "qsp";
    rev = "00faed4590a9032f0cd9e436663123503de5a4ce";
    hash = "sha256-x0nPiBWC7QrE4L5LG568objyB0BgdDbPaO+0KbkJrDU=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  prePatch = ''
    install -Dm644 ${./QspConfig.cmake.in} QspConfig.cmake.in
    substituteInPlace CMakeLists.txt \
      --replace-fail " onig " " "
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [ oniguruma ];

  cmakeFlags = [ (lib.cmakeBool "USE_INSTALLED_ONIGURUMA" true) ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/QSPFoundation/qsp";
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Interactive fiction development platform (Game Library)";
    homepage = "https://github.com/QSPFoundation/qsp";
    license = lib.licenses.gpl2Only;
  };
})
