{ stdenv, lib, pkgs, fetchFromGitHub, withoutWallet ? false, withZMQ ? false
, withGui ? false, qtbase ? null, qttools ? null, wrapQtAppsHook ? null }:

stdenv.mkDerivation rec {
  pname = if withGui then "particl-qt" else "particl-daemon";

  version = "0.19.99.1.0-g6805257";

  src = fetchFromGitHub {
    owner = "particl";
    repo = "particl-core";
    rev = "6805257331ee9cb8f6b98dba94c15cb7d2578dfa";
    sha256 = "k4e5A3nuL6RMRDgVZBusvkc1iztsmAdiOTwdwiZlkho=";
  };

  nativeBuildInputs = with pkgs;
    [ pkgconfig autoreconfHook ] ++ lib.optionals withGui [ wrapQtAppsHook ];

  buildInputs = with pkgs;
    [ boost170 miniupnpc_2 libevent zlib unixtools.hexdump python3 ]
    ++ lib.optionals (!withoutWallet) [ db48 ]
    ++ lib.optionals withGui [ qtbase qttools qrencode protobuf hidapi libusb ]
    ++ lib.optionals withZMQ [ zeromq ];

  configureFlags = [
    "CFLAGS=-O2"
    "CXXFLAGS=-O2"
    "--enable-hardening"
    "--enable-upnp-default"
    "--disable-bench"
    "--with-boost-libdir=${pkgs.boost170.out}/lib"
  ] ++ lib.optionals stdenv.cc.isClang [ "CXX=clang++" "CC=clang" ]
    ++ lib.optionals withoutWallet [ "--disable-wallet" ]
    ++ lib.optionals withGui [
      "--with-gui=qt5"
      "--enable-usbdevice=yes"
      "--with-qt-bindir=${qtbase.dev}/bin:${qttools.dev}/bin"
    ]
    ++ lib.optionals (!doCheck) [ "--enable-tests=no" "--enable-gui-tests=no" ];

  # Try to minimize memory usage
  CXXFLAGS = "--param ggc-min-expand=1 --param ggc-min-heapsize=32768";

  checkInputs = with pkgs; [ rapidcheck python3 ];

  # Always check during Hydra builds
  doCheck = true;
  checkFlags = [
    "LC_ALL=C.UTF-8"
  ]
  # QT_PLUGIN_PATH needs to be set when executing QT, which is needed when testing Bitcoin's GUI.
  # See also https://github.com/NixOS/nixpkgs/issues/24256
    ++ lib.optionals withGui
    [ "QT_PLUGIN_PATH=${qtbase}/${qtbase.qtPluginPrefix}" ];

  preCheck = "patchShebangs test";

  enableParallelBuilding = false;

  meta = let
    variantDescription =
      if withGui then "Qt Wallet" else "RPC daemon and CLI client";
  in with lib; {
    description = "Privacy Coin & Decentralized Ecosystem";
    longDescription = ''
      PART is a Proof-of-Stake and privacy-focused cryptocurrency based on the Bitcoin codebase.
      ${variantDescription}.
    '';
    homepage = "https://particl.io/";
    maintainers = with maintainers; [ demyanrogozhin ];
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
