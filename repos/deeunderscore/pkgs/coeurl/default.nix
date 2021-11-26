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
  version = "unstable-2021-11-21";

  src = fetchFromGitLab {
    domain = "nheko.im";
    owner = "nheko-reborn";
    repo = "coeurl";
    rev = "abafd60d7e9f5cce76c9abad3b2b3dc1382e5349";
    sha256 = "sha256-IMj8qK9OQ5C1+LTs+pBJXxkqY0+Pz0AjsffkHshWVcg=";
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