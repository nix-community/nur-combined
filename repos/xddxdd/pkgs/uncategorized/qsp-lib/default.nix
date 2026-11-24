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
  version = "5.9.5-unstable-2026-11-23";
  src = fetchFromGitHub {
    owner = "QSPFoundation";
    repo = "qsp";
    rev = "737f7d101bd4ec057ead36a0128369e0dfcc3118";
    hash = "sha256-i+r/CTFuhEg1gIrbKjG2JZtRnZZ5tE9MLPHGY5Ldf5w=";
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
