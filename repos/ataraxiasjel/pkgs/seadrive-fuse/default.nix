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
  version = "3.0.17";

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-yh2LnHP6VmGnixapy56dSNwtU/mY3R4RVPLXL/iceRY=";
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
