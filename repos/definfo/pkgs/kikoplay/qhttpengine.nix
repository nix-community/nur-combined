{
  fetchFromGitHub,
  stdenv,
  lib,
  cmake,
  qt6,
}:
stdenv.mkDerivation {
  pname = "qhttpengine";
  version = "0-unstable-2025-03-05";
  src = fetchFromGitHub {
    owner = "YaKho";
    repo = "qhttpengine";
    rev = "7b9fb190d2e1f66fe32f38a9242f7827dcb62b57";
    hash = "sha256-/x8MuxCg08p+lRL/swVuy63EQl88+Xd4GY3LdwHJsIQ=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.2.0)" "cmake_minimum_required(VERSION 3.12)"
  '';

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [ qt6.qtbase ];

  meta = {
    maintainers = with lib.maintainers; [
      definfo
      xddxdd
    ];
    description = "HTTP server for Qt applications";
    homepage = "https://github.com/YaKho/qhttpengine";
    license = lib.licenses.mit;
  };
}
