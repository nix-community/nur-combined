{ 
  stdenv, 
  dpkg, 
  fetchurl,
  autoPatchelfHook
}:

stdenv.mkDerivation rec {
  name = "dumb-hello";

  src = fetchurl {
    urls = [
      "http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.13_amd64.deb"
      "http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libcrypto1.0.0-udeb_1.0.2n-1ubuntu5.13_amd64.udeb"
    ];
    hash = "sha256-7RRVVnFHWi20gQSbS2bs03b3mnym1NeKFwL+sDeqVCI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    dpkg
  ];

  dontUnpack = true;

  buildPhase = ''
    source $stdenv/setup
    PATH=$dpkg/bin:$PATH

    dpkg -x $src unpacked
  '';

  installPhase = ''
    mkdir -p $out/lib $out/share
    cp -r unpacked/usr/lib/x86_64-linux-gnu/* $out/lib
    cp -r unpacked/usr/share/* $out/share
  '';
}