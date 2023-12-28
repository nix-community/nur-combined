{ lib
, stdenv
, fetchFromGitHub
, libsolv
, asciidoctor
, cmake
, doxygen
, gettext
, graphviz
, ninja
, nginx
, pkg-config
, vsftpd
, boost
, curl
, fcgi
, gpgme
, libproxy
, libsigcxx
, libxml2
, pcre2
, protobuf
, readline
, rpm
, systemd
, yaml-cpp
, nix-update-script
}:
let
  libsolv' = libsolv.overrideAttrs (prevAttrs: {
    cmakeFlags = prevAttrs.cmakeFlags ++ [
      "-DENABLE_HELIXREPO=true"
    ];
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libzypp";
  version = "17.31.27";

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "libzypp";
    rev = finalAttrs.version;
    hash = "sha256-8B1hzYBJ/ZWiRnInmFgjXvSpz6laPbhMYNS092wZeDQ=";
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
    vsftpd
  ];

  buildInputs = [
    boost
    curl
    fcgi # for nginx
    gpgme
    libproxy
    libsigcxx
    libsolv'
    libxml2
    pcre2
    protobuf
    readline
    rpm
    systemd
    yaml-cpp
  ];

  cmakeFlags = [
    "-DCMAKE_MODULE_PATH=${libsolv'}/share/cmake/Modules"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "ZYpp Package Management library";
    homepage = "https://github.com/openSUSE/libzypp";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
