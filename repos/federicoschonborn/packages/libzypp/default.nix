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
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libzypp";
  version = "17.31.23";

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "libzypp";
    rev = finalAttrs.version;
    hash = "sha256-fv1gQBdGvlaqzWPbL5njQy8OUW32VIm0vbg27okdNlg=";
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "ZYpp Package Management library";
    homepage = "https://github.com/openSUSE/libzypp";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
