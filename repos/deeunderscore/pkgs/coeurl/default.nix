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
  version = "0.1.1";

  src = fetchFromGitLab {
    domain = "nheko.im";
    owner = "nheko-reborn";
    repo = "coeurl";
    rev = "v${version}";
    sha256 = "sha256-F4kHE9r2pR8hI+CrZQ9ElPjtp0McgwfSxoD5p56KDGs=";
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