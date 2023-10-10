{ lib
, stdenv
, fetchFromGitHub
, asciidoctor
, boost
, cmake
, ninja
, curl
, doxygen
, fcgi
, gettext
, gpgme
, graphviz
, libproxy
, libsigcxx
, libsolv
, libxml2
, nginx
, pcre2
, pkg-config
, protobuf
, readline
, rpm
, systemd
, yaml-cpp
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libzypp";
  version = "17.31.21";

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "libzypp";
    rev = finalAttrs.version;
    hash = "sha256-2RBaSCYceVZnQNaZ5vUgo5hiqTVTDf26+eeCHtlAC0s=";
  };

  patches = [
    ./libdir.patch
  ];

  nativeBuildInputs = [
    asciidoctor
    cmake
    doxygen
    gettext
    graphviz
    ninja
    nginx # asciidoctor requires this ???
    pkg-config
  ];

  buildInputs = [
    boost
    curl
    fcgi # for nginx
    gpgme
    libproxy
    libsigcxx
    libsolv
    libxml2
    pcre2
    protobuf
    readline
    rpm
    systemd
    yaml-cpp
  ];

  cmakeFlags = [
    "-DCMAKE_MODULE_PATH=${libsolv}/share/cmake/Modules"
  ];

  meta = with lib; {
    description = "ZYpp Package Management library";
    homepage = "https://github.com/openSUSE/libzypp";
    license = with licenses; [ gpl2Plus ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
})
