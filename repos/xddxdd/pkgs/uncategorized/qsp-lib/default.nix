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
  version = "5.9.5-unstable-2026-09-30";
  src = fetchFromGitHub {
    owner = "QSPFoundation";
    repo = "qsp";
    rev = "73d45270fd08d79607923e4382b303d25e8e5020";
    hash = "sha256-NJsY44xJrSNAGLhWD6gqSayJ1aLxV9zl+NS7qyedL8Y=";
  };
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
