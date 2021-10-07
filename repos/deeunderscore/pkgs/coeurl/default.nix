{ lib
, stdenv
, fetchgit
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
  version = "unstable-2021-08-13";

  src = fetchgit {
    url = "https://nheko.im/nheko-reborn/coeurl.git";
    rev = "22f58922da16c3b94d293d98a07cb7caa7a019e8";
    sha256 = "sha256-bslkrBjAsf2co4lt9efEQ3R6YNR2+minZAKkcZKjykI=";
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