{ lib
, stdenv
, fetchFromGitLab
, meson
, ninja
, pkg-config
, curl
, libevent
, spdlog
, doctest
}:
stdenv.mkDerivation rec {
  name = "coeurl";
  version = "unstable-2022-11-20";

  src = fetchFromGitLab {
    domain = "nheko.im";
    owner = "nheko-reborn";
    repo = "coeurl";
    rev = "f989f3c54c1ca15e29c5bd6b1ce4efbcb3fd8078";
    hash = "sha256-xj8AWrEtM3nLx9SLlwoOqQxLOrRnE+i/CdVlDNcds98=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  buildInputs = [
    curl
    libevent
    spdlog
  ];

  checkInputs = [
    doctest
  ];

  meta = with lib; {
    description = "A simple async wrapper around CURL for C++";
    homepage = "https://nheko.im/nheko-reborn/coeurl";
    license = licenses.mit;
  };
}