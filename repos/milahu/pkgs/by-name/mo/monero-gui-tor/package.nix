{
  lib,
  stdenv,
  makeDesktopItem,
  monero-gui,
  torsocks,
}:

stdenv.mkDerivation rec {
  pname = "monero-gui-tor";
  inherit (monero-gui) version;

  dontUnpack = true;

  desktopItem = makeDesktopItem {
    name = "monero-wallet-gui-tor";
    exec = "monero-wallet-gui-tor";
    icon = "monero";
    desktopName = "Monero-Tor";
    genericName = "Wallet";
    categories = [
      "Network"
      "Utility"
    ];
  };

  buildPhase = ''
    cat >monero-wallet-gui-tor <<'EOF'
    #!/bin/sh

    # based on
    # https://www.getmonero.org/resources/user-guides/tor_wallet.html#gui

    # see also
    # https://monero.fail/?chain=monero&network=mainnet&type=onion

    exec ${torsocks}/bin/torsocks \
      ${monero-gui}/bin/monero-wallet-gui \
      "$@"

    # TODO?
    exec ${monero-gui}/bin/monero-wallet-gui \
      --socks5-proxy 127.0.0.1:9050 \
      "$@"
    EOF
    chmod +x monero-wallet-gui-tor
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp monero-wallet-gui-tor $out/bin

    # install desktop entry
    install -Dm644 -t $out/share/applications \
      ${desktopItem}/share/applications/*

    # install icons
    mkdir -p $out/share
    ln -s ${monero-gui}/share/icons $out/share/icons
  '';

  meta = {
    description = "Torified Monero wallet GUI";
    homepage = "https://getmonero.org/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    mainProgram = "monero-gui-tor";
  };
}
