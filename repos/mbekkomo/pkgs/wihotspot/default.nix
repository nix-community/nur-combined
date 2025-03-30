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
  ];

  patches = [
    ./build.patch
  ];

  makeFlags = [
    "DESTDIR=$(out)"
  ];

  postInstall = ''
    wrapProgram $out/bin/create_ap \
      --set PATH ${
        lib.makeBinPath [
          util-linux
          procps
          hostapd
          iproute2
          iw
          wirelesstools
          haveged
        ]
      } 
  '';
}
