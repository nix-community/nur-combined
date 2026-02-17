{
  # Options
  withGui ? false,

  # Helpers
  lib,
  stdenv,
  fetchFromGitHub,

  # Dependencies
  ## Native
  autoreconfHook,
  pkg-config,
  python3,
  util-linux,
  wrapQtAppsHook ? null,
  ## Runtime
  boost,
  libevent,
  openssl,
  fmt,
  zlib,
  miniupnpc,
  zeromq,
  db4,
  sqlite,
  qtbase ? null,
  qttools ? null,
  qrencode ? null,
}:

assert withGui -> (qtbase != null && qttools != null && qrencode != null && wrapQtAppsHook != null);

stdenv.mkDerivation (finalAttrs: {
  pname = if withGui then "litecoin" else "litecoin-cli";
  version = "0.21.4";

  src = fetchFromGitHub {
    owner = "litecoin-project";
    repo = "litecoin";
    rev = "beae01d62292a0aab363b7a4d3f606708cea7260";
    hash = "sha256-39+lGWnsK2kq7iUveey98mMAVHCu4tWY8BEzY1rJZcU=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    python3
    util-linux
  ]
  ++ lib.optionals withGui [
    wrapQtAppsHook
    qtbase
    qttools
  ];

  buildInputs = [
    boost
    libevent
    openssl
    fmt
    zlib
    miniupnpc
    zeromq
    db4
    sqlite
  ]
  ++ lib.optionals withGui [
    qtbase
    qttools
    qrencode
  ];

  configureFlags = [
    "--with-boost-libdir=${boost.out}/lib"
    "--with-incompatible-bdb"
    "--disable-bench"
  ]
  ++ lib.optionals (!withGui) [
    "--without-gui"
    "--without-qrencode"
  ]
  ++ lib.optionals (withGui) [
    "LRELEASE=${qttools.dev}/bin/lrelease"
  ];

  doChecks = true;

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Peer-to-peer electronic cash system (Litecoin)";
    homepage = "https://litecoin.org/";
    mainProgram = if withGui then "litecoin-qt" else "litecoin-cli";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
