{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  qmake,
  cmake,
  pkg-config,
  wrapQtAppsHook,
  miniupnpc,
  bzip2,
  speex,
  libmicrohttpd,
  libxml2,
  libxslt,
  sqlcipher,
  rapidjson,
  libxscrnsaver,
  qtbase,
  qtx11extras,
  qtmultimedia,
  libgnome-keyring,
  json_c,
  botan2,
  tor,
  gnupg,
}:

stdenv.mkDerivation rec {
  pname = "retroshare";
  version = "0.6.7.3-38dc687";

  src = fetchFromGitHub {
    owner = "RetroShare";
    repo = "RetroShare";
    # rev = "v${version}";
    rev = "38dc687e66fe79e8fac47e487e68673be24e5fa0";
    hash = "sha256-VYx4jQai4ZCnTMf0FbxnHHVAAuGIdbZESPDdSZSFZOk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    qmake
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    speex
    miniupnpc
    qtmultimedia
    qtx11extras
    qtbase
    libgnome-keyring
    bzip2
    libxscrnsaver
    libxml2
    libxslt
    sqlcipher
    libmicrohttpd
    rapidjson
    json_c
    botan2
  ];

  qmakeFlags = [
    # Upnp library autodetection doesn't work
    "RS_UPNP_LIB=miniupnpc"

    # These values are normally found from the .git folder
    "RS_MAJOR_VERSION=${lib.versions.major version}"
    "RS_MINOR_VERSION=${lib.versions.minor version}"
    "RS_MINI_VERSION=${lib.versions.patch version}"
    "RS_EXTRA_VERSION="
  ];

  postPatch = ''
    # Build libsam3 as C, not C++. No, I have no idea why it tries to
    # do that, either.
    substituteInPlace libretroshare/src/libretroshare.pro \
      --replace-fail \
        "LIBSAM3_MAKE_PARAMS =" \
        "LIBSAM3_MAKE_PARAMS = CC=$CC AR=$AR"

    # return fake git tags
    mkdir $TMP/bin
    cat >$TMP/bin/git <<'EOF'
    #!/bin/sh
    echo 0.0.0
    EOF
    chmod +x $TMP/bin/git
    export PATH="$TMP/bin:$PATH"

    substituteInPlace libretroshare/src/tor/TorManager.cpp \
      --replace \
        '"/usr/bin/tor"' \
        '"${tor}/bin/tor"'

    substituteInPlace supportlibs/librnp/src/tests/data/cli_EncryptSign/regenerate_keys \
      --replace \
        '"/usr/bin/gpg"' \
        '"${gnupg}/bin/gpg"'
  '';

  postInstall = ''
    # BT DHT bootstrap
    cp libbitdht/src/bitdht/bdboot.txt $out/share/retroshare
  '';

  meta = {
    description = "Decentralized peer to peer chat application";
    homepage = "https://retroshare.cc/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ StijnDW ];
  };
}
