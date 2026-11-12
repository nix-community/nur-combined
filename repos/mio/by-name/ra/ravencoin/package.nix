{
  lib,
  stdenv,
  pkgs,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  boost,
  libevent,
  openssl,
  db48,
  zeromq,
  miniupnpc,
  qrencode,
  protobuf,
  qt5,
  symlinkJoin,
  python3,
  versionCheckHook,
  withGui ? true,
  withWallet ? true,
  withZmq ? true,
  withUpnp ? true,
}:

let
  # configure searches only --with-qt-bindir for lrelease, which lives in a
  # different output than moc/uic/rcc.
  qtTools = symlinkJoin {
    name = "ravencoin-qt-tools";
    paths = [
      qt5.qtbase.dev
      qt5.qttools.dev
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = if withGui then "ravencoin" else "ravend";
  version = "4.8.0";

  src = fetchFromGitHub {
    owner = "RavenProject";
    repo = "Ravencoin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W8mG1H6wp+lBEbWBkxNZtK4myXAq3L9AuhvD3//+rJ0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    # configure records PYTHON, which check-local uses for raven-util-test.py.
    python3
    # configure aborts without hexdump when tests are enabled. Only the bin
    # output may be used: util-linux's libuuid headers shadow the SDK's
    # uuid/uuid.h and break the Cocoa include chain.
    (lib.getBin pkgs.util-linux)
  ]
  ++ lib.optionals withGui [
    qt5.qttools
    qt5.wrapQtAppsHook
  ];

  patches = [
    ./boost-system-header-only.patch
    ./boost-filesystem-v4.patch
    ./miniupnpc-api18.patch
    ./disable-secp256k1-openssl-tests.patch
  ];

  buildInputs = [
    boost
    libevent
    openssl
  ]
  ++ lib.optionals withWallet [ db48 ]
  ++ lib.optionals withZmq [ zeromq ]
  ++ lib.optionals withUpnp [ miniupnpc ]
  ++ lib.optionals withGui [
    protobuf
    qrencode
    qt5.qtbase
  ];

  configureFlags = [
    "--with-gui=${if withGui then "qt5" else "no"}"
    (lib.enableFeature withWallet "wallet")
    (lib.withFeature withZmq "zmq")
    (lib.withFeature withUpnp "miniupnpc")
    (lib.withFeature withGui "qrencode")
    "--with-boost=${boost}"
    "--with-boost-libdir=${boost}/lib"
  ]
  ++ lib.optionals withGui [ "--with-qt-bindir=${qtTools}/bin" ];

  enableParallelBuilding = true;

  doCheck = true;

  # Wallet tests create their databases below HOME.
  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = lib.optionalString (withGui && stdenv.hostPlatform.isLinux) ''
    install -Dm644 share/pixmaps/raven256.png $out/share/icons/hicolor/256x256/apps/ravencoin.png
    install -Dm644 contrib/debian/raven-qt.desktop $out/share/applications/raven-qt.desktop
    substituteInPlace $out/share/applications/raven-qt.desktop \
      --replace-fail "Icon=raven128" "Icon=ravencoin"
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/ravend";
  doInstallCheck = true;

  meta = {
    description = "Peer-to-peer digital asset blockchain, forked from Bitcoin Core";
    longDescription = ''
      Ravencoin is an open-source blockchain project derived from Bitcoin Core.
      It adds asset issuance, messaging and rewards on top of a Bitcoin-style
      UTXO chain, and ships the ravend daemon, raven-cli and the raven-qt
      graphical wallet.
    '';
    homepage = "https://ravencoin.org/";
    downloadPage = "https://github.com/RavenProject/Ravencoin/releases/tag/v${finalAttrs.version}";
    changelog = "https://github.com/RavenProject/Ravencoin/blob/v${finalAttrs.version}/doc/release-notes.md";
    license = lib.licenses.mit;
    mainProgram = if withGui then "raven-qt" else "ravend";
    platforms = lib.platforms.unix;
  };
})
