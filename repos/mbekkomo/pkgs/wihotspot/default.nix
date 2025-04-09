{
  stdenv,
  lib,
  fetchFromGitHub,
  wrapGAppsHook3,
  makeWrapper,
  gnumake,
  pkg-config,
  gtk3,
  qrencode,
  libpng,
  util-linux,
  procps,
  hostapd,
  iproute2,
  iw,
  wirelesstools,
  haveged,
  bash,
  dnsmasq,
  iptables,
}:
stdenv.mkDerivation {
  pname = "wihotspot";
  version = "0-unstable-2025-03-12";

  src = fetchFromGitHub {
    owner = "lakinduakash";
    repo = "linux-wifi-hotspot";
    rev = "c0f153bff954542c5f0e551bfcad791f44ac345e";
    hash = "sha256-20yhcBhVlObl/aZKH4P2tdAeutTpZo+R0//i0/uAPFw=";
  };

  nativeBuildInputs = [
    gnumake
    pkg-config
    wrapGAppsHook3
    makeWrapper
  ];

  buildInputs = [
    gtk3
    libpng.dev
    qrencode.dev
    util-linux
    procps
    hostapd
    iproute2
    iw
    wirelesstools
    haveged
    bash
    dnsmasq
    iptables
  ];

  patches = [
    ./build.patch
    ./wihotspot.patch
  ];

  makeFlags = [
    "DESTDIR=$(out)"
  ];

  postInstall = ''
    for x in create_ap wihotspot-gui; do
      wrapProgram $out/bin/$x \
        --prefix PATH : ${
          lib.makeBinPath [
            bash
            util-linux
            procps
            hostapd
            iproute2
            iw
            wirelesstools
            haveged
            dnsmasq
            iptables
          ]
        }
    done
    rm -f $out/bin/wihotspot
    ln -s $out/bin/wihotspot{-gui,}
  '';
}
