{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,

  cli11,
  gtest,
  libcap,
  nlohmann_json,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "linyaps-box";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "OpenAtom-Linyaps";
    repo = "linyaps-box";
    tag = finalAttrs.version;
    hash = "sha256-rOuPq+R0tllQiwPIoPj1YuUBxRH9Gsr3qlr5W88M6Xo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cli11
    gtest
    libcap
    nlohmann_json
  ];

  meta = {
    description = "Simple OCI runtime mainly used by linyaps";
    homepage = "https://github.com/OpenAtom-Linyaps/linyaps-box";
    mainProgram = "ll-box";
    platforms = lib.platforms.linux;
    license = lib.licenses.lgpl3Plus;
  };
})
