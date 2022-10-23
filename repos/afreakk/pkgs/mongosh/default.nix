{ stdenv
, autoPatchelfHook
, fetchurl
, xz
, e2fsprogs
, cyrus_sasl
, libkrb5
, openssl_1_1
}:
stdenv.mkDerivation rec {
  name = "mongosh";
  version = "1.0.4";
  src = fetchurl {
    url = "https://downloads.mongodb.com/compass/mongosh-${version}-linux-x64.tgz";
    sha256 = "0w6hn1vlq6rxph2bnqnm1mn28chz00xkipxsnj970bzr4awg5g5g";
  };
  buildInputs = [
    # for libssl.so.1.1 & libcrypto.so.1.1
    openssl_1_1
    # for liblzma.so.5
    xz
    # for libcom_err.so.2
    e2fsprogs
    # for libsasl2.so.3 & libkrb5.so.3 & libgssapi_krb5.so.2
    cyrus_sasl
    libkrb5
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out
    tar -zxvf $src -C $out
    mv $out/mongosh-${version}-linux-x64/* $out
    rmdir $out/mongosh-${version}-linux-x64
    # cant find libsasl2.so.2, but cyrus_sasl has libsasl2.so.3, so maybe this will be ok
    patchelf --replace-needed libsasl2.so.2 libsasl2.so.3 $out/bin/mongocryptd-mongosh
  '';
  nativeBuildInputs = [
    autoPatchelfHook
  ];
}
