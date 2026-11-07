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
  version = "5.9.5-unstable-2026-11-06";
  src = fetchFromGitHub {
    owner = "QSPFoundation";
    repo = "qsp";
    rev = "1d20d47e2654bf318ba6174efdf5c4c7e6d8dff0";
    hash = "sha256-VzQblXr/al0Ius0Ae/gYu+cIX7i1C3WdRSj+dEseAvA=";
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
