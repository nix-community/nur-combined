{
  alsa-lib,
  autoPatchelfHook,
  cairo,
  coreutils,
  cups,
  curl,
  dpkg,
  fetchurl,
  gdk-pixbuf,
  glib,
  harfbuzz,
  lib,
  libGL,
  libayatana-appindicator,
  libgbm,
  libgcc,
  libpulseaudio,
  makeWrapper,
  nspr,
  nss,
  pango,
  perl,
  procps,
  squashfsTools,
  stdenv,
  xorg,
  unzip,
  util-linux,
  zip,
}:

stdenv.mkDerivation rec {
  name = "spotx";
  version = "1.2.63.394.g126b0d89";

  dontUnpack = true;
  src = fetchurl {
    url = "https://repository.spotify.com/pool/non-free/s/spotify-client/spotify-client_${version}_amd64.deb";
    hash = "sha256-mcIp+CnMucKhiL6A0SQdK4yP018ejXc0OMD2EtaOlA4=";
  };

  # snap = fetchurl {
  #   url = "https://api.snapcraft.io/api/v1/snaps/download/pOBIoZ2LrCB3rDohMxoYGnbN14EHOgD7_88.snap";
  #   hash = "sha256-M+p728Kk+BmykEnEwXsGQvx3ZirwQHL+o3JQj5PUCDE=";
  # };

  spotx = fetchurl {
    url = "https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/868fb87e29680d9ed26e0f689e7fe73a03092a35/spotx.sh";
    hash = "sha256-t1l547o8HA0w8cnWo3uR4EPAzc3nOPVShAI+3UQtY+k=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    coreutils
    curl
    dpkg
    libgcc
    makeWrapper
    perl
    procps
    squashfsTools
    unzip
    util-linux
    zip
  ];
  buildInputs = [
    alsa-lib
    cairo
    cups
    gdk-pixbuf
    glib
    harfbuzz
    libGL
    libayatana-appindicator
    libgbm
    libpulseaudio
    nspr
    nss
    pango
    xorg.libX11
  ];

  #patches = [ ./spotx.diff ];
  myPatch = ./spotx.diff;
  buildPhase = ''
    ar x ${src}
    mkdir data
    cd data
    tar -xf ../data.tar.gz
    cd ..
    cat ${spotx} > spotx.sh
    cat ${myPatch} | patch

    sh spotx.sh -P data/usr/share/spotify
    mkdir $out
    mv data $out/opt
  '';

  installPhase = ''
    makeWrapper $out/opt/usr/bin/spotify $out/bin/spotx
  '';

  meta = {
    description = "Custom version of Spotify";
    license = lib.licenses.gpl2;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
