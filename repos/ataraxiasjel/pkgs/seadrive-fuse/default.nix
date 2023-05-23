{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, autoreconfHook
, libsearpc
, libuuid
, libtool
, libevent
, sqlite
, openssl
, fuse
, vala
, intltool
, jansson
, curl
, python3
}:

stdenv.mkDerivation rec {
  pname = "seadrive-fuse";
  version = "2.0.22";

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-zzUg3ukV3bf0X+LYDmDgB6TXfDx388q4RvVCAnKzauE=";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [
    libsearpc
    libuuid
    libtool
    libevent
    sqlite
    openssl.dev
    fuse
    vala
    intltool
    jansson
    curl
    python3
  ];

  meta = with lib; {
    homepage = "https://github.com/haiwen/seadrive-fuse";
    description = "SeaDrive daemon with FUSE interface";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
