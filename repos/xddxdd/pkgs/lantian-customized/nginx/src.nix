{
  sources,
  stdenv,
  bash,
  perl,
  cacert,
  curl,
  dos2unix,
}:
stdenv.mkDerivation {
  pname = "openresty-src";
  inherit (sources.openresty) version src;

  nativeBuildInputs = [
    bash
    perl
    curl
    dos2unix
  ];

  postPatch = ''
    sed -i "s/wget/curl/g" util/get-tarball
    sed -i "s/-O/-Lo/g" util/get-tarball
    sed -i "/nginx_xml2pod/d" util/mirror-tarballs
    sed -i "/restydoc_index/d" util/mirror-tarballs
    sed -i "s/hg /true /g" util/mirror-tarballs
    sed -i "s/git /true /g" util/mirror-tarballs
    sed -i "/cd nginx.org/d" util/mirror-tarballs
  '';

  buildPhase = ''
    patchShebangs util/
    bash -x util/mirror-tarballs
  '';

  installPhase = ''
    mkdir -p $out
    tar xvf openresty-*.tar.gz -C $out --strip-components=1

    sed -i "s|#!${perl}/bin/perl|#!/usr/bin/env perl|g" $out/bundle/install
    sed -i "s|#!${perl}/bin/perl|#!/usr/bin/env perl|g" $out/configure
    sed -i "s|#!${bash}/bin/bash|#!/usr/bin/env bash|g" $out/util/package-win32.sh
    sed -i '/# configure restydoc indexes/,/# prepare nginx configure line/d;' $out/configure
  '';

  dontFixup = true;

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-E5B8yfgkA8bL9TcRckqYTHBLv5++XTFSlSgY1fUtSQc=";
}
