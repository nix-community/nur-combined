{
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
  autoreconfHook,
  curl,
  fuse,
  intltool,
  jansson,
  libargon2,
  libevent,
  libsearpc,
  libtool,
  libuuid,
  libwebsockets,
  openssl,
  python3,
  sqlite,
  vala,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "seadrive-fuse";
  version = "3.0.12";

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-XvWaj83PGDjvIU8prHw8uyifpRqmO8S1IVE2wvpD5yA=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];
  buildInputs = [
    curl
    fuse
    intltool
    jansson
    libargon2
    libevent
    libsearpc
    libtool
    libuuid
    libwebsockets
    openssl.dev
    python3
    sqlite
    vala
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://github.com/haiwen/seadrive-fuse";
    description = "SeaDrive daemon with FUSE interface";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "seadrive";
  };
}
